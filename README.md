# Oqs

Post-quantum signatures and key exchange for Ziran, from [liboqs](https://github.com/open-quantum-safe/liboqs)
(Open Quantum Safe).

```sh
ziran add https://github.com/ziranlang/oqs.git
```

```jai
#import "oqs/Oqs"

Sign :: (message: []u8) -> bool {
    public_key: [MlDsa44PublicKeyBytes]u8
    secret_key: [MlDsa44SecretKeyBytes]u8
    signature: [MlDsa44SignatureBytes]u8
    if !MlDsa44KeyPair(public_key[:], secret_key[:]) { return false }
    length := MlDsa44Sign(signature[:], message, secret_key[:])
    return length > 0 &&
        MlDsa44Verify(message, signature[0:length], public_key[:])
}
```

| Procedure | Does |
|---|---|
| `MlDsa44KeyPair(public_key, secret_key)` | Makes an ML-DSA-44 (FIPS 204) key pair |
| `MlDsa44Sign(signature, message, secret_key)` | Signs; returns the signature's length, or -1 |
| `MlDsa44Verify(message, signature, public_key)` | Checks a signature |
| `RandomBytes(output)` | Fills bytes from the system's secure random source |
| `Cleanse(memory)` | Zeroes secrets in a way the compiler keeps |

`MlKem768KeyPair`, `MlKem768Encapsulate`, and `MlKem768Decapsulate` provide
ML-KEM-768 (FIPS 203) key exchange. Their key, ciphertext and shared-secret
sizes are the `MlKem768*Bytes` constants. Decapsulation of an altered
ciphertext produces a different shared secret; its success result alone
does not authenticate a peer.

The wrappers take slices and refuse buffers too small for keys, signatures,
ciphertexts or shared secrets, and lengths a 32-bit `size_t` cannot hold.
The current API covers ML-DSA-44 and ML-KEM-768, secure random bytes and
secret cleansing. It does not expose every algorithm in liboqs.

## Linking liboqs

The repository contains the Ziran API. The complete original liboqs source
is a Git source dependency pinned to an exact commit in `ziran.lock`;
`ziran fetch --locked` retrieves it and `ziran pkg path liboqs` locates it.
This serves the same purpose as an upstream submodule through Ziran's
package system.

Build the pinned static and shared libraries on Linux:

```sh
make native
```

Then link with `LDFLAGS=-L/path/to/build/native LDLIBS=-loqs`. Go uses cgo
(`CGO_ENABLED=1`); Rust carries the flags in its generated Cargo project.
Python uses ctypes and the shared `liboqs.so`; add that directory to
`LD_LIBRARY_PATH` when running it. C and C++ call the same native ABI.

`make check` builds the libraries and exercises signing, tamper rejection,
empty messages, key exchange, random bytes, cleansing and short-buffer
rejection on C, C++, Go, Rust and Python, from source and saved `.zir`.
`make check TARGET=go` selects one backend. A C compiler, CMake, Python,
Go and Cargo are required for the full check. The portable `.zib` VM does
not call arbitrary C libraries; this package requires a native backend.
