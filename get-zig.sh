#!/usr/bin/env bash
set -euxo pipefail

os=linux
remove_others=true

arch=$(uname -m)
version=$(curl https://ziglang.org/download/index.json | jq -r .master.version)
name="zig-${os}-${arch}-${version}"
archive="${name}.tar.xz"
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

if [[ "$remove_others" == true ]]; then
    find toolchain/download/ -maxdepth 1 -mindepth 1 | while read path; do
        if [[ "$path" != "toolchain/download/$archive" ]] && \
            [[ "$path" != "toolchain/download/${archive}.minisig" ]]; then
            rm "$path"
        fi
    done
fi

tar -C toolchain/versions -xf toolchain/download/${archive}

rm -f zig
ln -s toolchain/versions/${name}/zig zig

if [[ "$remove_others" == true ]]; then
    find toolchain/versions/ -maxdepth 1 -mindepth 1 | while read path; do
        if [[ "$path" != "toolchain/versions/$name" ]]; then
            rm -rf "$path"
        fi
    done
fi
