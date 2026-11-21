#!/bin/sh
set -eu

case "$1" in
    all) targets='c go' ;;
    c|go) targets=$1 ;;
    *) printf 'Unsupported native target: %s\n' "$1" >&2; exit 2 ;;
esac

unset DISPLAY WAYLAND_DISPLAY
export LD_LIBRARY_PATH="$PWD/build/native${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export LDFLAGS="-L$PWD/build/native ${LDFLAGS:-}"
export LDLIBS="${LDLIBS:-} -loqs"
export GO111MODULE=off CGO_ENABLED=1
out=$PWD/build/backends
source=tests/oqs_test.zi
entry=oqs_test:main

"$ZIRAN" check --project ${LOCK_FLAGS:-} "$source"
"$ZIRAN" ir --project ${LOCK_FLAGS:-} --entry "$entry" -o "$out/ir" "$source"

run_test() {
    target=$1
    form=$2
    shift 2
    destination="$out/$target/$form"
    if [ "$target" = go ]; then
        "$ZIRAN" build --target=go --pkg main --exe --entry "$entry" -o "$destination" "$@"
        (cd "$destination" && go build -o oqs_test .)
    else
        "$ZIRAN" build --target=c --exe --entry "$entry" -o "$destination" "$@"
    fi
    "$destination/oqs_test"
    printf 'PASS %s (%s)\n' "$target" "$form"
}

for target in $targets; do
    run_test "$target" source --project ${LOCK_FLAGS:-} "$source"
    run_test "$target" saved --root "$out/ir" "$out/ir"/*.zir
done
