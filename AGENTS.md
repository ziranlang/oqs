# Oqs agent guide

Post-quantum signatures and key exchange for Ziran, backed by liboqs (Open
Quantum Safe). `check` signs and verifies against liboqs built from the locked
source with ML-DSA-44 and ML-KEM-768.

## Layout

- `src/Oqs.zi` — the module, exported as `Oqs`; import `oqs/Oqs`. Procedures:
  `MlDsa44KeyPair/Sign/Verify`, `MlKem768KeyPair/Encapsulate/Decapsulate`, ...
  (table in README).
- `tests/` — the sign/verify and KEM suites.
- `Makefile` — `check` (default), `test`, `prepare`, `native`, `clean`;
  liboqs is configured into `build/liboqs` and archived to
  `build/native/liboqs.a` (`-DBUILD_SHARED_LIBS=OFF -DOQS_BUILD_ONLY_LIB=ON
  -DOQS_USE_OPENSSL=OFF -DOQS_DIST_BUILD=OFF`).
- `ziran.toml` / `ziran.lock` — identity, locked toolchain and the liboqs
  dependency (source build from upstream `main`); an ignored
  `ziran.local.toml` drops `--locked`.

## Commands

- `make prepare` — `ziran fetch` (downloads the pinned dependencies).
- `make native` — build `build/native/liboqs.a` from the locked liboqs source.
- `make check` — default goal; runs `test`, which needs the liboqs archive.

## Pins

- Toolchain: `ziran.lock` pins ziran.git
  `5db3d3c39425d5dfe4bfe4a84e6f6e2e5a810ad0`.
- Dependency: liboqs `https://github.com/open-quantum-safe/liboqs.git`,
  `main`, built from source (`source = true`).
- Consumers: `ziran add https://git.waozi.xyz/ziranlang/oqs.git`.

## Question -> file

- Which algorithms and procedure signatures? -> README table, `src/Oqs.zi`.
- How is liboqs built? -> `Makefile` (`native` target).
- Which toolchain/dependency revisions? -> `ziran.toml`, `ziran.lock`.
