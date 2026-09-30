.DEFAULT_GOAL := check

ZIRAN ?= ziran
CC ?= cc
CMAKE ?= cmake
BUILD := build
TARGET ?= all
LOCK_FLAGS := $(if $(wildcard ziran.local.toml),,--locked)
LIBOQS_BUILD := $(BUILD)/liboqs
LIBOQS_A := $(BUILD)/native/liboqs.a

.PHONY: check test native prepare clean

# Checks the package, then signs and verifies against liboqs built from the
# locked source with ML-DSA-44 and ML-KEM-768.
check: test

prepare:
	$(ZIRAN) fetch $(LOCK_FLAGS)

native: $(LIBOQS_A)

$(LIBOQS_A): Makefile ziran.lock $(wildcard ziran.local.toml) | prepare
	$(CMAKE) -S "$$($(ZIRAN) pkg path liboqs)" -B $(LIBOQS_BUILD) \
		-DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF \
		-DOQS_BUILD_ONLY_LIB=ON -DOQS_USE_OPENSSL=OFF -DOQS_DIST_BUILD=OFF \
		-DOQS_OPT_TARGET=generic '-DOQS_MINIMAL_BUILD=SIG_ml_dsa_44;KEM_ml_kem_768' \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON
	$(CMAKE) --build $(LIBOQS_BUILD) --target oqs
	mkdir -p $(BUILD)/native
	$(CC) -shared -Wl,--whole-archive $(LIBOQS_BUILD)/lib/liboqs.a \
		-Wl,--no-whole-archive -o $(BUILD)/native/liboqs.so
	cp $(LIBOQS_BUILD)/lib/liboqs.a $@

test: native
	python3 "$$($(ZIRAN) pkg path ziran)/scripts/test_native_package.py" \
		--ziran "$(ZIRAN)" --source tests/oqs_test.zi --entry oqs_test:main \
		--library-dir $(BUILD)/native --libraries=-loqs --target $(TARGET)

clean:
	rm -rf $(BUILD)
