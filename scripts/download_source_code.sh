#!/usr/bin/env bash

set -x

VERSION=$1
GLIBC_HOME="/opt/glibc"
sudo mkdir -p $GLIBC_HOME/source
cd $GLIBC_HOME/source

if [ ! -d "$GLIBC_HOME/source/glibc-$VERSION" ]; then
    sudo wget "http://mirrors.ustc.edu.cn/gnu/libc/glibc-$VERSION.tar.gz"
    sudo tar -xf glibc-$VERSION.tar.gz
else
    echo "[*] $GLIBC_HOME/source/glibc-$VERSION already exists"
fi
