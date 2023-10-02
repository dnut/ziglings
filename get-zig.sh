#!/usr/bin/env bash
set -euxo pipefail

os=linux
arch=x86_64
version=0.12.0-dev.706+62a0fbdae
archive="zig-${os}-${arch}-${version}.tar.xz"
pubkey=RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U

mkdir -p toolchain/download
mkdir -p toolchain/versions

check-download() {
    minisign -V -P "$pubkey" \
        -x toolchain/download/${archive}.minisig \
        -m toolchain/download/${archive}
}

check-download || {
    wget -P toolchain/download "https://ziglang.org/builds/$archive"
    wget -P toolchain/download "https://ziglang.org/builds/${archive}.minisig"
}

tar -C toolchain/versions -xf toolchain/download/${archive}

ln -s toolchain/versions/zig-${os}-${arch}-${version}/zig zig
