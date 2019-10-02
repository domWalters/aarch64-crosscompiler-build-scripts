# AArch64 GCC Cross Compiler

This repo contains a set of scripts that allow for easily downloading, configuring, and building an AArch64 Cross Compiler with all the standard C and C++ libraries.

This is intended for use on Centos7, where the default aarch64 compiler available through yum lacks any additional libraries.

The script install the compiler to /opt/cross by default.

# Usage

When running for the first time:

```bash

sudo chmod +x setup.sh && sudo chmod +x run.sh
sudo ./setup.sh -download -unpack && sudo ./run.sh

```

If some kind of error occurs and you need to continue the build process, it is recommended to begin the process again from the unpacking step (as well as to start in a new terminal to reset the environment):

```bash

sudo ./setup.sh -unpack && sudo ./run.sh

```
