#!/bin/bash

# AppVeyor and Drone Continuous Integration for MSYS2
# Author: Renato Silva <br.renatosilva@gmail.com>
# Author: Qian Hong <fracting@gmail.com>

# Functions
success() { echo "Build success: ${@}"; exit 0; }
failure() { echo "Build failure: ${@}"; exit 1; }

# Prepare
git config --global user.email 'ci@msys2.org'
git config --global user.name 'MSYS2 Continuous Integration'
pacman --sync --needed --noconfirm --noprogressbar binutils || failure 'could not install binutils'

# Recipes
cd "$(dirname "$0")"
files=($(git show -m --pretty=format: --name-only))
for file in "${files[@]}"; do
    [[ "${file}" = */PKGBUILD ]] && recipes+=("${file}")
done
test -n "${files}"   || failure 'could not detect changed files'
test -z "${recipes}" && success 'no changes in package recipes'

# Build
for recipe in "${recipes[@]}"; do
    cd "$(dirname ${recipe})"
    echo "Build start: $(dirname ${recipe})"
    makepkg --syncdeps --noconfirm --skippgpcheck --nocheck --noprogressbar || failure "could not build ${recipe}"
    cd - > /dev/null
done

# Install
pacman -U --noconfirm */*.pkg.tar.xz
