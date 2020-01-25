#!/usr/bin/env bash
set -euo pipefail
trap 'this_command=$BASH_COMMAND previous_command=$this_command; ' DEBUG
trap 'echo FAILED COMMAND: $previous_command' EXIT

#-------------------------------------------------------------------------------------------
# This script will download packages for, configure, build and install a GCC cross-compiler.
# Customize the variables (INSTALL_PATH, TARGET, etc.) to your liking before running.
# If you get an error and need to resume the script from some point in the middle,
# just delete/comment the preceding lines before running it again.
#
# See: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler
#-------------------------------------------------------------------------------------------

# Variables set to newest downloadable values as of 2nd October 2019.
# GCC Version chosen to tie in with Centos7 devtoolset-8.
source ./versions.sh
TARGET=aarch64-linux
LINUX_ARCH=arm64
CONFIGURATION_OPTIONS="--disable-multilib" # --disable-threads --disable-shared
PARALLEL_MAKE=-j4
case ":${PATH:=$INSTALL_PATH/bin}:" in
  *:"$INSTALL_PATH/bin":*)    ;;
  *) export PATH=$INSTALL_PATH/bin:$PATH;;
esac

# Step 1. Binutils
mkdir -p build-binutils
cd build-binutils
../$BINUTILS_VERSION/configure --prefix=$INSTALL_PATH --target=$TARGET $CONFIGURATION_OPTIONS
make $PARALLEL_MAKE
make install
cd ..

# Step 2. Linux Kernel Headers
if [ $USE_NEWLIB -eq 0 ]; then
  cd $LINUX_KERNEL_VERSION
  make ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$INSTALL_PATH/$TARGET headers_install
  cd ..
fi

# Step 3. C/C++ Compilers
mkdir -p build-gcc
cd build-gcc
if [ $USE_NEWLIB -ne 0 ]; then
  NEWLIB_OPTION=--with-newlib
fi
../$GCC_VERSION/configure --prefix=$INSTALL_PATH --target=$TARGET --enable-languages=c,c++ $CONFIGURATION_OPTIONS $NEWLIB_OPTION
make $PARALLEL_MAKE all-gcc
make install-gcc
cd ..

if [ $USE_NEWLIB -ne 0 ]; then
  # Steps 4-6: Newlib
  mkdir -p build-newlib
  cd build-newlib
  ../newlib-master/configure --prefix=$INSTALL_PATH --target=$TARGET $CONFIGURATION_OPTIONS
  make $PARALLEL_MAKE
  make install
  cd ..
else
  # Step 4. Standard C Library Headers and Startup Files
  mkdir -p build-glibc
  cd build-glibc
  ../$GLIBC_VERSION/configure --prefix=$INSTALL_PATH/$TARGET --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-headers=$INSTALL_PATH/$TARGET/include $CONFIGURATION_OPTIONS libc_cv_forced_unwind=yes
  make install-bootstrap-headers=yes install-headers
  make $PARALLEL_MAKE csu/subdir_lib
  install csu/crt1.o csu/crti.o csu/crtn.o $INSTALL_PATH/$TARGET/lib
  $TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $INSTALL_PATH/$TARGET/lib/libc.so
  touch $INSTALL_PATH/$TARGET/include/gnu/stubs.h
  cd ..

  # Step 5. Compiler Support Library
  cd build-gcc
  make $PARALLEL_MAKE all-target-libgcc
  make install-target-libgcc
  cd ..

  # Step 6. Standard C Library & the rest of Glibc
  cd build-glibc
  make $PARALLEL_MAKE
  make install
  cd ..
fi

# Step 7. Standard C++ Library & the rest of GCC
cd build-gcc
make $PARALLEL_MAKE all
make install
cd ..

trap - EXIT
echo 'Success!'
