#!/usr/bin/env bash

# --- mips 大端 ---
sudo apt install -y \
    linux-libc-dev-mips-cross \
    libc6-mips-cross libc6-dev-mips-cross \
    binutils-mips-linux-gnu \
    gcc-mips-linux-gnu g++-mips-linux-gnu

# --- mipsel 小端 ---
sudo apt install -y \
    linux-libc-dev-mipsel-cross \
    libc6-mipsel-cross libc6-dev-mipsel-cross \
    binutils-mipsel-linux-gnu \
    gcc-mipsel-linux-gnu g++-mipsel-linux-gnu
