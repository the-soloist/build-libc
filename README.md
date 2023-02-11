# build libc

一键编译常见架构的 libc，默认运行环境为 64 bits x86_64。

目前已支持 glibc、musl-libc。

## Usage

查看帮助：

```
bash ./build.sh -l "glibc" -h
bash ./build.sh -l "musl-libc" -h
```

参数解释：

- `-a`：编译架构
- `-c`：自定义编译选项
- `-d`：下载
- `-n`：自定义保存名称
- `-t`：编译线程
- `-v`：libc 版本

例子：

```sh
# 关闭 tcache，安装路径为 glibc/<arch>/<version>-no_tcache
bash ./build.sh -l "glibc" -a x86_64 -v 2.3x -c "--disable-experimental-malloc" -n "no_tcache"
# 使用 16 线程编译
bash ./build.sh -l "glibc" -a x86_64 -v 2.3x -t 16
# 编译所有版本 glibc（不推荐）
bash ./build.sh -l "glibc" -a x86_64 -v all
# 仅下载 glibc 源码
bash ./build.sh -l "glibc" -d 2.3x
# 查看 glibc 的帮助信息
bash ./build.sh -l "glibc" -h
```

使用前请将 `build.sh` 中的 LIBC_HOME 修改为自定义路径，默认为 `/opt/<libc>`。

脚本运行中下载的 libc 源码与 install 路径均存放 LIBC_HOME 下。

可以在 bashrc 中添加一个 alias，方便使用

```sh
alias build-libc="bash /path/to/build-libc/build.sh"
```
