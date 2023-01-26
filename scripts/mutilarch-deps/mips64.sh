#!/usr/bin/env bash

# --- mips64 大端 ---
sudo apt install -y \
    linux-libc-dev-mips64-cross \
    libc6-mips64-cross libc6-dev-mips64-cross \
    binutils-mips64-linux-gnuabi64 \
    gcc-mips64-linux-gnuabi64 g++-mips64-linux-gnuabi64

# --- mips64el 小端 ---
sudo apt install -y \
    linux-libc-dev-mips64el-cross \
    libc6-mips64el-cross libc6-dev-mips64el-cross \
    binutils-mips64el-linux-gnuabi64 \
    gcc-mips64el-linux-gnuabi64 g++-mips64el-linux-gnuabi64
