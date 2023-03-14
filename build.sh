#!/usr/bin/env bash
# set -x

DATA_HOME="/opt"
WORK_HOME="$(dirname $(readlink -f "$0"))"

source "$WORK_HOME/lib/utils.sh"

# parse args
while getopts "l:a:v:c:n:t:d:mh" OPT; do
    case $OPT in
    l) # load libc compile functions
        if [ ! -f "$WORK_HOME/lib/build-$OPTARG.sh" ]; then
            echo "$WORK_HOME/lib/build-$OPTARG.sh is not exist"
            exit 1
        else
            source "$WORK_HOME/lib/build-$OPTARG.sh"
        fi ;;
    a) LIBC_ARCH="$OPTARG" ;;
    v) LIBC_VERSION="$OPTARG" ;;
    c) CUSTOM_CONFIG="$OPTARG" ;;
    n) CUSTOM_NAME="$OPTARG" ;;
    t) COMPILE_THREAD="$OPTARG" ;;
    m) # compile with more debug info
        CFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -w"
        CXXFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -w"
        ;;
    d) # just download libc source code
        init_libc_home
        download_libc_source "$OPTARG"
        clean_libc_trash "$OPTARG"
        exit 0
        ;;
    h) print_help ;;
    ?) print_help ;;
    esac
done

### init vars
NOW_TIME=$(date "+%Y-%m-%d_%H:%M:%S")

LIBC_HOME="/$DATA_HOME/$LIBC_FULL_NAME"
BUILD_LOG="/tmp/log/build-$LIBC_FULL_NAME"
LOG_CONFIGURE="$BUILD_LOG/configure_$NOW_TIME.log"
LOG_MAKE="$BUILD_LOG/make_$NOW_TIME.log"
LOG_MAKE_INSTALL="$BUILD_LOG/make-install_$NOW_TIME.log"

COMPILE_THREAD="8"
CUSTOM_NAME="\"ignore this unless you set custom config (-c)\""

### check args
if [ -z "$LIBC_ARCH" ] && [[ "${LIBC_ARCH_ARRAY[@]}" =~ "$LIBC_ARCH" ]]; then
    echo -e "please set LIBC_ARCH\n"
    print_help
fi
if [ -z "$LIBC_VERSION" ] && [[ "${LIBC_VERSION_ARRAY[@]}" =~ "$LIBC_VERSION" ]]; then
    echo -e "please set LIBC_VERSION\n"
    print_help
fi

### init build env
init_libc_home
init_complie_args "$LIBC_ARCH"
install_complie_dependence "$LIBC_ARCH"

### print start info
print_start_info
pause

if [ -n "$LIBC_VERSION" ] && [ "$LIBC_VERSION" != "all" ]; then
    echo -e "\n### compile $LIBC_VERSION ###\n"
    download_libc_source "$LIBC_VERSION"
    clean_libc_trash "$LIBC_VERSION"
    install_libc "$LIBC_ARCH" "$LIBC_VERSION"
    print_end_info
else
    for LIBC_VERSION in ${LIBC_VERSION_ARRAY[@]}; do
        echo -e "\n### compile $LIBC_VERSION ###\n"
        download_libc_source "$LIBC_VERSION"
        clean_libc_trash "$LIBC_VERSION"
        install_libc "$LIBC_ARCH" "$LIBC_VERSION"
        print_end_info
    done
fi
