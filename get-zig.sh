#!/usr/bin/env bash
set -euxo pipefail

os=linux
arch=$(uname -m)
version=$(curl https://ziglang.org/download/index.json | jq -r .master.version)
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
    rm -f toolchain/download/${archive}
    rm -f toolchain/download/${archive}.minisig
    wget -P toolchain/download "https://ziglang.org/builds/${archive}"
    wget -P toolchain/download "https://ziglang.org/builds/${archive}.minisig"
    check-download
}

tar -C toolchain/versions -xf toolchain/download/${archive}

rm -f zig
ln -s toolchain/versions/zig-${os}-${arch}-${version}/zig zig
