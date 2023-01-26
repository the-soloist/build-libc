# build libc

一键编译常见架构的 libc，默认环境为 64 bits x86_64

## Usage

```
> bash ./build.sh -h
Usage:
    bash ./build.sh [-l LIBC_FULL_NAME] [-a LIBC_ARCH] [-v LIBC_VERSION] [-t THREAD] [-c CUSTOM_CONFIG] [-n CUSTOM_NAME]
            [-d download_libc] [-m more_debug_info]

    option -l:
        glibc
        musl-libc

    option -a:
        x86 x86_64
        arm-linux-gnueabi   arm-linux-gnueabihf   aarch64-linux-gnu
        mips-linux-gnu      mipsel-linux-gnu      mips64-linux-gnuabi64   mips64el-linux-gnuabi64
        riscv64-linux-gnu

    option -v:
        all

    option -c:
        --disable-experimental-malloc: disable tcache

    examples:
        bash ./build.sh -l "glibc" -a x86_64 -v all
        bash ./build.sh -l "glibc" -a x86_64 -v 2.3x -t 16
        bash ./build.sh -l "glibc" -a x86_64 -v 2.3x -c "--disable-experimental-malloc" -n "no_tcache"
        bash ./build.sh -l "glibc" -d 2.3x
        bash ./build.sh -l "musl-libc" -d 1.2.x
        bash ./build.sh -l "musl-libc" -a x86_64 -v 1.2.x
```

参数解释

```
-a: compile architecture
-v: glibc version
-d: download glibc source code
-c: custom compile config
-n: custom save name
-t: compile thread
-m: add more debug info
```

使用前请将 `build-<libc>.sh` 中的 LIBC_HOME 修改为自定义路径，默认为 `/opt/<libc>`。

脚本运行中下载的 libc 源码与 install 路径均存放 LIBC_HOME 下。

可以在 bashrc 中添加一个 alias，方便使用

```sh
alias build-libc="bash /path/to/build-libc/build.sh"
```
