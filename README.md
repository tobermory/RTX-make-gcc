# Composing Keil RTX Applications Using gcc/make

On various forums I frequent, e.g.

* [Keil](https://community.arm.com/developer/tools-software/tools/f/keil-forum)

* [GNU Toolchain](https://community.arm.com/developer/tools-software/oss-platforms/f/gnu-toolchain-forum)

* [Silicon Labs](https://www.silabs.com/community/mcu/32-bit/forum)

the question sometimes pops up 'Can I build RTX with gcc/make' ? The
answer, is yes, and this is how to do it...

## The Prerequisites

GNU Make and the arm-none-eabi toolchain, both available on your
PATH. Author has v4.1 and v7.3.1 respectively, on Ubuntu 18LTS.

## The Preparation

```
$ mkdir SOME_HOME_FOR_CMSIS_5
$ cd    SOME_HOME_FOR_CMSIS_5
$ git clone https://github.com/ARM-software/CMSIS_5.git
$ cd CMSIS_5 && git checkout 5.6.0
```
Other tags may work too, I have built against 5.6.0 for a year or two.

Then, return to this project and

```
$ edit ./Makefile such that

CMSIS_5_HOME = SOME_HOME_FOR_CMSIS_5/CMSIS_5
```

## The Build

See ./Makefile for more commentary, but essentially

```
$ make lib
```

should produce libRTX_CM3.a. Then

```
$ make examples
```

should fail. This is intentional.

```
$ make localize
```

copies a RTX_Config.h and rtx_lib.c file from the RTX source tree into

```
./src/test/include/RTX_Config.h

./src/test/c/rtx_lib_local.c
```

You configure RTX (thread count, tick freq, stack checking, etc) for
your application(s) by editing the now-local RTX_Config.h and
rebuilding rtx_lib_local.c. For now, no edits needed. The presence of
the files is what matters. The examples should now build:

```
$ make examples
```

should produce kernelStart.bin, with its .axf sibling, along with a
.map file.  How you flash the .bin file to your target is a separate
issue (but one that I also do via make!)

## An M4 Build

By default, this Makefile builds for a Cortex M3 (author's system). M4
settings are also included, so

$ make clean
$ make CM4=1
$ make examples CM4=1

Alternatively, edit the Makefile to include cm4.mk rather than cm3.mk, then
an M4 build will default.

## The Details

We are just cherry-picking sources from the CMSIS_5 source tree that
we grabbed from [github](https://github.com/ARM-software/CMSIS_5).  We
use GNU Make's VPATH and CPPFLAGS variables to reference rather than
copy the required files. We don't edit *any* file in the retrieved
CMSIS_5 bundle.

We copy just TWO files to our local application: RTX_Config.h and
rtx_lib.c.  These form the 'constructor' of RTX in any RTX-using
application --- space is allocated for various control blocks, thread
stacks, etc. The space needed could not possibly be known at libRTX.a
build time, we need this postponed build step.

Via Make's VPATH and CPPFLAGS, we are referencing RTX and other
CMSIS_5 files from these directories:

```
CMSIS_5/CMSIS/Core/
CMSIS_5/CMSIS/RTOS2/Include
CMSIS_5/CMSIS/RTOS2/Source
CMSIS_5/CMSIS/RTOS2/RTX/Config
CMSIS_5/CMSIS/RTOS2/RTX/Include
CMSIS_5/CMSIS/RTOS2/RTX/Source
CMSIS_5/CMSIS/RTOS2/RTX/Source/GCC
CMSIS_5/Device/ARM/ARMCM3|4/Include
CMSIS_5/Device/ARM/ARMCM3|4/Source
CMSIS_5/Device/ARM/ARMCM3|4/Source/GCC
```

We build a libRTX.a from files in the above tree.  The libRTX.a lives
in our project directory, in this case, in this directory:

```
myproj/libRTX.a
```

We then copy two such files:

```
CMSIS_5/CMSIS/RTOS2/RTX/Config/RTX_Config.h
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_lib.x
```

into our project:

```
myProj/src/test/include/RTX_Config.h
myProj/src/test/c/rtx_lib_local.c
```

and combine rtx_lib_local.c with any application file, after
configuring RTX for that application via edits to (the localized) RTX_Config.h.


```
gcc mApp.c rtx_lib_local.c libRTX.a -o myApp.axf
```

Alternatively, you could bypass the .a file, and link your
applications via inclusion of *.o from RTX:

```
gcc mApp.c rtx_lib_local.c $(RTX_OBJS) -o myApp.axf
```

sdmaclean AT gmail.com

