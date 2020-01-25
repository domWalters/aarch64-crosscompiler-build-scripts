#!/usr/bin/env bash
cd "${0%/*}"
source ./versions.sh

if [ "$#" -gt 1 ]; then
  echo "Too many arguments."
  echo "Usage: ./setup.sh [--clean --download --unpack]"
fi

case $1 in
  --clean)
    # Remove packages
    rm *.tar.*
    # Remove unpack locations
    rm -rf binutils-*/
    rm -rf cloog-*/
    rm -rf gcc-*/
    rm -rf glibc-*/
    rm -rf gmp-*/
    rm -rf isl-*/
    rm -rf linux-*/
    rm -rf mpc-*/
    rm -rf mpfr-*/
    # Remove build directores
    rm -rf build-*/
    # Remove INSTALL_PATH
    while true; do
      read -p "Warning: This script is going to delete $INSTALL_PATH. Are you sure you wish to continue? (y/n))" yn
      case $yn in
        [Yy]*)
          sudo rm -r $INSTALL_PATH
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
    ;;
  --download)
    # Download packages
    wget -nc https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.gz
    wget -nc https://ftp.gnu.org/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz
    if [ $USE_NEWLIB -ne 0 ]; then
      wget -nc -O newlib-master.zip https://github.com/bminor/newlib/archive/master.zip
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
  --unpack)
    # Unpack
    for f in *.tar*; do
      echo "Unpacking $f..."
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
    echo "Invalid argument."
    echo "Usage: ./setup.sh [--clean --download --unpack]"
    exit 1
    ;;
esac
