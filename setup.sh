#!/usr/bin/env bash
set -euo pipefail
cd "${0%/*}"
source ./versions.sh

if [ "$#" -gt 1 ]; then
  echo "Too many arguments."
  echo "Usage: ./setup.sh [--download --unpack]"
fi

while true; do
  read -p "Warning: This script is going to delete $INSTALL_PATH. Are you sure you wish to continue? (y/n))" yn
  case $yn in
    [Yy]*)
      rm -r $INSTALL_PATH || true
      rm -r build-*/ || true
      break
      ;;
    [Nn]*)
      exit 0
      ;;
    *)
      echo "Please answer, y or n."
      ;;
  esac
done

case $1 in
  "--download")
    # Download packages
    rm *.tar.*
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
    ;&
  "--unpack")
    # Remove unpack locations
    rm -r binutils-*/ || true
    rm -r cloog-*/ || true
    rm -r gcc-*/ || true
    rm -r glibc-*/ || true
    rm -r gmp-*/ || true
    rm -r isl-*/ || true
    rm -r linux-*/ || true
    rm -r mpc-*/ || true
    rm -r mpfr-*/ || true
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
    cd ../
    ;;
  *)
    echo "Invalid argument: $var"
    exit 1
    ;;
esac
