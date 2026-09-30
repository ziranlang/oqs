.DEFAULT_GOAL := check

ZIRAN ?= ziran
CC ?= cc
CMAKE ?= cmake
BUILD := build
LIBOQS_BUILD := $(BUILD)/liboqs
LIBOQS_A := $(LIBOQS_BUILD)/lib/liboqs.a

.PHONY: check test clean

# Checks the package, then signs and verifies against liboqs built from the
# locked source with only ML-DSA-44.
check: test

$(LIBOQS_A):
	$(CMAKE) -S "$$($(ZIRAN) pkg path liboqs)" -B $(LIBOQS_BUILD) \
		-DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF \
		-DOQS_BUILD_ONLY_LIB=ON -DOQS_USE_OPENSSL=OFF -DOQS_DIST_BUILD=OFF \
		-DOQS_OPT_TARGET=generic -DOQS_MINIMAL_BUILD=SIG_ml_dsa_44
	$(CMAKE) --build $(LIBOQS_BUILD) --target oqs

test: $(LIBOQS_A)
	$(ZIRAN) check --project
	$(ZIRAN) build --project --target=c --entry oqs_test:main \
		-o $(BUILD)/test-c tests/oqs_test.zi
	$(CC) -std=c11 -I$$($(ZIRAN) pkg path ziran)/include -I$(BUILD)/test-c \
		$(BUILD)/test-c/*.c $(LIBOQS_A) -o $(BUILD)/oqs-test
	$(BUILD)/oqs-test

clean:
	rm -rf $(BUILD)
