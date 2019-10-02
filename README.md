# AArch64 GCC Cross Compiler
This repo contains a set of scripts that allow for easily downloading, configuring, and building an AArch64 Cross Compiler with all the standard C and C++ libraries.

This is intended for use on Centos7, where the default aarch64 compiler available through yum lacks any additional libraries.

The scripts install the compiler to /opt/cross by default.

# Usage
When running for the first time:

```bash

chmod +x setup.sh run.sh
sudo ./setup.sh --download && sudo ./run.sh

```

If some kind of error occurs and you need to continue the build process, it is recommended to begin the process again from the unpacking step (as well as to start in a new terminal to reset the environment):

```bash

sudo ./setup.sh --unpack && sudo ./run.sh

```

# Acknowledgements
These scripts are based on a [post from preshing.com](https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/) along with the [github gist](https://gist.github.com/preshing/41d5c7248dea16238b60) that is available on that site.
