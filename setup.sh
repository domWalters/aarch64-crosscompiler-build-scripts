#!/usr/bin/env bash
set -euo pipefail
cd "${0%/*}"
source ./versions.sh

if [ "$#" -gt 2 ]; then
    echo "Too many arguments."
    echo "Usage: ./setup.sh [-redownload -reunpack]"
fi

while true; do
    read -p "Warning: This script is going to delete $INSTALL_PATH. Are you sure you wish to continue?" yn
    case $yn in
        [Yy]* ) rm -r $INSTALL_PATH && rm -r build-*/; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer, yes or no.";;
    esac
done

for var in "$@"; do
    case $var in
        "-download" ) 
            # Download packages
            export http_proxy=$HTTP_PROXY https_proxy=$HTTP_PROXY ftp_proxy=$HTTP_PROXY
            wget -nc https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.gz
            wget -nc https://ftp.gnu.org/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz
            if [ $USE_NEWLIB -ne 0 ]; then
                wget -nc -O newlib-master.zip https://github.com/bminor/newlib/archive/master.zip || true
                unzip -qo newlib-master.zip
            else
                wget -nc https://www.kernel.org/pub/linux/kernel/v4.x/$LINUX_KERNEL_VERSION.tar.xz
                wget -nc https://ftp.gnu.org/gnu/glibc/$GLIBC_VERSION.tar.xz
            fi
            wget -nc https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.xz
            wget -nc https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
            wget -nc https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz
            wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2
            wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz      
            break;;
        "-unpack" ) 
            # Remove unpack locations
            rm -r binutils-*/
            rm -r cloog-*/
            rm -r gcc-*/
            rm -r glibc-*/
            rm -r gmp-*/
            rm -r isl-*/
            rm -r linux-*/
            rm -r mpc-*/
            rm -r mprf-*/
            # Unpack
            for f in *.tar*; do 
                tar xfk $f
            done
            # Make symbolic links
            cd $GCC_VERSION
            ln -sf `ls -1d ../mpfr-*/` mpfr
            ln -sf `ls -1d ../gmp-*/` gmp
            ln -sf `ls -1d ../mpc-*/` mpc
            ln -sf `ls -1d ../isl-*/` isl
            ln -sf `ls -1d ../cloog-*/` cloog
            cd ..
            break;;
        * ) echo "Invalid argument: $var" && exit;;
    esac
done
