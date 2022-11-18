# build glibc

一键编译/交叉编译常见架构的 glibc

## Usage

```
> bash ./build.sh -h
Usage:
    bash ./build.sh [-a arch] [-v glibc_version] [-m more_debug_info] [-d download_glibc] [-c set_custom_config] [-n set_custom_name]

    option -a:
        x64 x86
        arm-linux-gnueabi   arm-linux-gnueabihf     aarch64-linux-gnu
        mips-linux-gnu      mips64-linux-gnuabi64   mipsel-linux-gnu    mips64el-linux-gnuabi64

    option -v:
        all 2.19 2.23 2.24 2.25 2.26 2.27 2.28 2.29 2.30 2.31 2.32 2.33 2.34 2.35 2.36

    option -c
        --disable-experimental-malloc: disable tcache

    examples:
        bash ./build.sh -a x64 -v all
        bash ./build.sh -a x64 -v 2.3x
        bash ./build.sh -a x64 -v 2.3x -c "--disable-experimental-malloc" -n "no_tcache"
        bash ./build.sh -d 2.3x
```

参数解释

```
-a: compile architecture
-v: glibc version
-m: add more debug info
-d: download glibc source code
-c: custom compile config
-n: custom save name
```

使用前请将 `build.sh` 中的 LIBC_HOME 修改为自定义路径，默认为 `/opt/glibc`。

脚本运行中下载的 glibc 源码与 install 路径均在 LIBC_HOME 下。

## 参考资料

1. https://github.com/ray-cp/pwn_debug/blob/master/build.sh
