#! /bin/bash

set -x

[ -r "$HOME/.makepkg.conf" ] && . "$HOME/.makepkg.conf"

cd "$(dirname "$0")" &&
. ./PKGBUILD &&
pkgver="$(git describe --tags | sed -n '/^v\([0-9.]\+\)-\([0-9]\+\)-\([0-9a-z]\+\)$/{s//\1.\2.\3/;p;Q0};Q1')" &&
src="src/$pkgname-$pkgver" &&
rm -rf src pkg &&
mkdir -p "$src" &&
sed "s/^pkgver=.*\$/pkgver=$pkgver/" PKGBUILD >PKGBUILD.tmp &&
(cd "$OLDPWD" && git ls-files -z | xargs -0 cp -a --no-dereference --parents --target-directory="$OLDPWD/$src") &&
export PACKAGER="${PACKAGER:-`git config user.name` <`git config user.email`>}" &&
export GIT_WORK_TREE="$PWD/$src" GIT_DIR="$OLDPWD/.git" &&
makepkg --noextract --force -p PKGBUILD.tmp &&
rm -rf src pkg PKGBUILD.tmp &&
sudo pacman -U --noconfirm "$pkgname-$pkgver-$pkgrel-any${PKGEXT:-.pkg.tar.xz}"
