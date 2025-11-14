#!/bin/sh

set -e

cd "$(dirname "$0")"

docker run --rm -i -v "$PWD":/data/ -w /data alpine:latest sh -s <<\EOF
apk add pacman p7zip

mkdir -p /usr/share/pacman/keyrings
wget https://github.com/msys2/MSYS2-keyring/raw/main/msys2.gpg -O /usr/share/pacman/keyrings/msys2.gpg

pacman-key --config pacman.conf --init
pacman-key --config pacman.conf --populate msys2

for ARCH in x86_64; do
    mkdir -p "$ARCH"/var/lib/pacman
    cp -r etc "$ARCH"/
    cp mintty-start.bat "$ARCH"/usr/bin/
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -Sy
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -S --noconfirm $(grep -v '^#' pkglist.txt)
    mkdir -p "$ARCH"/tmp  # required for bash / tmux.
    (cd "$ARCH" && 7z a ../"$ARCH".7z etc usr tmp;)
done
EOF
