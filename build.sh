#!/usr/bin/env bash
# set -x

WORK_HOME="$(dirname $(readlink -f "$0"))"

source "$WORK_HOME/utils.sh"

# parse args
while getopts "l:a:v:c:n:t:d:mh" OPT; do
    case $OPT in
    l) # load libc compile functions
        if [ ! -f "$WORK_HOME/build-$OPTARG.sh" ]; then
            echo "$WORK_HOME/build-$OPTARG.sh is not exist"
            exit 1
        else
            source "$WORK_HOME/build-$OPTARG.sh"
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
