#!/usr/bin/env bash

# --- arm ---
sudo apt install -y \
    linux-libc-dev-armhf-cross \
    libc6-armhf-cross libc6-dev-armhf-cross \
    libc6-armhf-armel-cross libc6-dev-armhf-armel-cross \
    binutils-arm-linux-gnueabihf \
    gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

sudo apt install -y \
    linux-libc-dev-armel-cross \
    libc6-armel-cross libc6-dev-armel-cross \
    libc6-armel-armhf-cross libc6-dev-armel-armhf-cross \
    binutils-arm-linux-gnueabi \
    gcc-arm-linux-gnueabi g++-arm-linux-gnueabi

sudo apt install -y \
    binutils-arm-none-eabi \
    gcc-arm-none-eabi
