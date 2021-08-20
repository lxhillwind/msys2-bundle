#!/bin/sh

set -e

cd "$(dirname "$0")"

docker run --rm -i -v $PWD/msys2/:/data/ -w /data alpine:latest sh -s <<\EOF
apk add pacman p7zip

mkdir -p /usr/share/pacman/keyrings
wget https://github.com/msys2/MSYS2-keyring/raw/master/msys2.gpg -O /usr/share/pacman/keyrings/msys2.gpg

pacman-key --config pacman.conf --init
pacman-key --config pacman.conf --populate msys2

for ARCH in i686 x86_64; do
    mkdir -p "$ARCH"/var/lib/pacman
    cp -r etc "$ARCH"/
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -Sy
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -S --noconfirm $(cat pkglist.txt)
    (cd "$ARCH" && 7z a ../"$ARCH".7z etc usr;)
done
EOF
