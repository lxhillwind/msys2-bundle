#!/bin/sh

set -e

cd "$(dirname "$0")"

docker run --rm -i -v "$PWD":/data/ -w /data alpine:latest sh -s <<\EOF
apk add pacman p7zip

mkdir -p /usr/share/pacman/keyrings
wget https://github.com/msys2/MSYS2-keyring/raw/master/msys2.gpg -O /usr/share/pacman/keyrings/msys2.gpg

pacman-key --config pacman.conf --init
pacman-key --config pacman.conf --populate msys2

for ARCH in i686 x86_64; do
    mkdir -p "$ARCH"/var/lib/pacman
    cp -r etc "$ARCH"/
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -Sy
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -S --noconfirm $(grep -v '^#' pkglist.txt)

    cp -a "$ARCH" "$ARCH"-new
    pacman --config pacman.conf --arch "$ARCH" -r "$ARCH" -S --noconfirm vim
    cp "$ARCH"/usr/bin/vim.exe "$ARCH"-new/usr/bin/vim.exe

    (cd "$ARCH"-new && 7z a ../"$ARCH".7z etc usr;)
done
EOF
