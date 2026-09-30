# Oqs

Post-quantum signatures for Ziran, from [liboqs](https://github.com/open-quantum-safe/liboqs)
(Open Quantum Safe).

```sh
ziran add https://github.com/ziranlang/oqs.git
```

```jai
#import "oqs/Oqs"

public_key: [MlDsa44PublicKeyBytes]u8;
secret_key: [MlDsa44SecretKeyBytes]u8;
signature: [MlDsa44SignatureBytes]u8;

Sign :: (message: []u8) -> bool {
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

The wrappers take slices and refuse buffers too small for a key or
signature, and lengths a 32-bit `size_t` cannot hold.

## Linking liboqs

The package pins liboqs as a source dependency. Build its static library
from the locked checkout and link it with your program:

```sh
cmake -S "$(ziran pkg path liboqs)" -B build/liboqs \
    -DBUILD_SHARED_LIBS=OFF -DOQS_BUILD_ONLY_LIB=ON -DOQS_USE_OPENSSL=OFF \
    -DOQS_DIST_BUILD=OFF -DOQS_MINIMAL_BUILD=SIG_ml_dsa_44
cmake --build build/liboqs --target oqs
```

`make` does this and runs the tests.
