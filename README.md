# Building Keil's RTX RTOS Using Make+GCC

On various forums I frequent, e.g.

* [Keil](https://community.arm.com/developer/tools-software/tools/f/keil-forum)

* [GNU Toolchain](https://community.arm.com/developer/tools-software/oss-platforms/f/gnu-toolchain-forum)

* [Silicon Labs](https://www.silabs.com/community/mcu/32-bit/forum)

the question sometimes pops up 'Can I build RTX with gcc/make' ? The
answer is yes, and this is how I do it, on Linux at least. YMMV on
other platforms.

## CMSIS_5 Releases/Tags, RTX versions

We align the tagged commits of this repo with that of the CMSIS_5 git
repo from ARM software, since that repo is home to the RTX sources. We
are simply providing a build process for that code.

Our
[5.8.0](https://github.com/tobermory/RTX-make-gcc/releases/tag/5.8.0)
tag uses the RTX sources labelled 5.5.3, as current in the CMSIS_5
[5.8.0](https://github.com/ARM-software/CMSIS_5/releases/tag/5.8.0) tag.

Our
[5.7.0](https://github.com/tobermory/RTX-make-gcc/releases/tag/5.7.0)
tag uses the RTX sources labelled 5.5.2, as current in the CMSIS_5
[5.7.0](https://github.com/ARM-software/CMSIS_5/releases/tag/5.7.0) tag.

Our
[5.6.0](https://github.com/tobermory/RTX-make-gcc/releases/tag/5.6.0)
tag uses the RTX sources labelled 5.5.1, as current in the CMSIS_5
[5.6.0](https://github.com/ARM-software/CMSIS_5/releases/tag/5.6.0) tag.


## The Prerequisites

GNU Make and the arm-none-eabi toolchain.  Ensure both are on your
PATH. Author has v4.1 and v8.2.1 respectively, on Ubuntu 18.04LTS.

## The Preparation

First, grab RTX sources from github.  They are just one component of
the larger CMSIS_5 code bundle:

```
$ mkdir SOME_HOME_FOR_CMSIS_5
$ cd    SOME_HOME_FOR_CMSIS_5
$ git   clone https://github.com/ARM-software/CMSIS_5.git
$ cd    CMSIS_5 && git checkout 5.8.0
```

Then, return to this project and

```
$ ed ./Makefile
```

such that

```
CMSIS_5_HOME = SOME_HOME_FOR_CMSIS_5/CMSIS_5
```

For those unlucky enough to have never crossed paths with
[ed](https://github.com/emacs-mirror/emacs/blob/master/etc/JOKES), it
is the true path to nirvana.

# The Build

The RTX 5.5.3 sources can be mostly built as a library (i.e. a .a
file) which can then be linked to your applications. We describe such
a build using gcc/make.

To configure the RTX parts of each application (tick frequency, thread
stacks, etc) requires including one RTX source file (rtx_lib.c) in
the build and link of each application. Again, we can do that using gcc/make.

Our goal is to make no edits to ANY RTX source file, be it a .c or a .h.

## Building RTX as a Library


See `./Makefile` for more commentary, but essentially

```
$ make
```

should produce `libRTX_CM3.a`. To see the gcc invocations in full, turn on
verbose mode:

```
$ make clean
$ make V=1
```

With the library built, proceed to build some example applications
(two trivial examples currently):

```
$ make examples
```

which should fail. This is intentional. There is a localize step:

```
$ make localize
```

which copies two files --- `RTX_Config.h` and `rtx_lib.c` --- from the
RTX source tree into

```
./src/test/include/RTX_Config.h

./src/test/c/rtx_lib_local.c
```

You configure RTX (thread count, tick freq, stack checking, etc) for
your application(s) by editing the now-local `RTX_Config.h` and
rebuilding `rtx_lib_local.c`. For now, no edits needed. The presence of
the files is what matters. The examples should now build:

```
$ make examples
```

should produce `kernelStart.bin`, with its .axf sibling, along with a
.map file.  How you flash the .bin file to your target is a separate
issue (but one that I also do via make!)

### An M4 Build

By default, this Makefile builds for a Cortex M3 (author's system). M4
settings are also included, so

```
$ make clean
$ make CM4=1
$ make examples CM4=1
```

Alternatively, edit the Makefile to `include cm4.mk` rather than
`include cm3.mk`, then an M4 build will default.

## The Details

We are just cherry-picking sources from the CMSIS_5 source tree that
we grabbed from [github](https://github.com/ARM-software/CMSIS_5).  We
use GNU Make's VPATH and CPPFLAGS variables (former locates .c files,
latter locates .h files) to reference-in-place rather than
copy-someplace-else each of the RTX sources. We don't edit *any* file in
the retrieved CMSIS_5 bundle. We *do* supply an empty
`RTE_Components.h` file, since that is referenced within the RTX
sources but not included (Keil provides it?).

Actually, we *do* copy two files to our local application:
`RTX_Config.h` and `rtx_lib.c`, for a very specific purpose. These
files form the 'constructor' of RTX in any RTX-using application ---
space is allocated for various control blocks, thread stacks, etc. The
space needed could not possibly be known at `libRTX.a` build time, we
need this postponed build step. `RTX_Config.h`, via a series of
#defines, describes how the RTX kernel will look (thread count, etc).
`rtx_lib.c` #includes `RTX_Config.h` and compiles those requirements.

Via VPATH and CPPFLAGS, we are referencing RTX and other
CMSIS_5 files from these directories:

```
CMSIS_5/CMSIS/Core/Include
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

We build a `libRTX.a` from files in the above tree.  The `libRTX.a` lives
in our project directory, in this case, in this directory:

```
./libRTX.a
```

We then copy two such files:

```
CMSIS_5/CMSIS/RTOS2/RTX/Config/RTX_Config.h
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_lib.x
```

into this project:

```
./src/test/include/RTX_Config.h
./src/test/c/rtx_lib_local.c
```

and combine `rtx_lib_local.c` with any application file, after
configuring RTX for that application via edits to (the localized)
`RTX_Config.h`:

```
gcc myApp.o rtx_lib_local.o libRTX.a -o myApp.axf
```

Alternatively, you could bypass the .a file, and link your
applications via inclusion of *.o from RTX:

```
gcc mApp.o rtx_lib_local.o $(RTX_OBJS) $(RTOS2_OBJS) -o myApp.axf
```

In this simple example, the `libRTX.a` build and example applications
are linked against that .a in the same project directory.  These need
not be combined, they could live in separate locations.

### The Localization

Why this somewhat ad-hoc localization step?

```
$ make
$ make localize
$ make examples
```

Why did we copy the two RTX files from the CMSIS_5 source tree into
our project, and use those in application builds? Worse, why did one
require a rename?

Well, imagine we were to *not* copy them, and that our application
depend on `rtx_lib.o` and not `rtx_lib_local.o`?  Well, then a linker
line of

```
gcc myApp.o rtx_lib.o libRTX.a -o myApp.axf
```

will still succeed, since VPATH includes the `RTX/Source` that is home
to `rtx_lib.c`. In fact, why make `rtx_lib.c` special at all?  If we
included it in the `libRTX.a` build in the first place, we'd just have

```
gcc myApp.o libRTX.a -o myApp.axf
```

The problem here is that the `rtx_lib.c` in the RTX source tree will
locate, via our CPPFLAGS, the `RTX_Config.h` file also in the RTX
tree, at `RTX/Config`. That file has sensible default settings (4K
total RTX memory footprint, tick freq of 1000, etc) for an RTX kernel.

But how then do you build applications A1 and A2, which have different
RTX requirements, if you have pre-compiled all parts of RTX into
libRTX.a? You can't. You made your `RTX_Config.h` decisions (or someone
else did) once, and are stuck with them.

So, we need an application-build-time compile of `rtx_lib.c`, against
a local `RTX_Config.h` that we can edit, and that's what we achieve
via the localization step. But why the rename, from `rtx_lib.c` to
`rtx_lib_local.c`?  Why this:

```
gcc myApp.o rtx_lib_local.o libRTX.a -o myApp.axf
```

and not just this:

```
gcc myApp.o rtx_lib.o libRTX.a -o myApp.axf
```

Well, the latter case will succeed even if we omit the localization
step. VPATH and CPPFLAGS will locate `rtx_lib.c` and `RTX_Config.h` in
the RTX source tree, defeating the point of the intended
localization. If the user forgets to `make localize`, their apps will
still build, but again, A1 and A2 can't co-exist. Only if our
application dependency graph is

```
gcc myApp.o rtx_lib_local.o libRTX.a -o myApp.axf
```

do we fail the build *unless* the localization step has been done.
And that failure *forces* the user to become aware of the need to
maintain an application-local `RTX_Config.h`. The forced rename of
`rtx_lib.c` is the vehicle used to highlight the need for a local
`RTX_Config.h`.

Clear as mud?

Note to RTX authors.  I think `RTX_Config.h` is erroneously included
by both `Include/rtx_evr.h` and `Source/rtx_lib.h`. Because of this,
the Makefile here has to include `RTX/Config` in CPPFLAGS. If I remove
the `#include RTX_Config.h` from these files, RTX will still build
from source.  The forced inclusion of RTX/Config in CPPFLAGS
exacerbates the issue of recognizing that `RTX_Config.h` is really an
end-user responsibility. I concede that it lives in a 'Config'
directory, which highlights it as different from other .h files, but
it is still referenced by the core RTX sources (which are all those
except `rtx_lib.c`).

## Other Devices

The build here used the 'Device' files `system_ARMCM3.c` and
`startup_ARMCM3.c`, together with the linker script `gcc_arm.ld`. We
also defined the Device Header to be `ARMCM3.h`.

These files describe the most basic of Cortex-M3 cpus, just the core
processor.  There are of course no peripherals, since these vary by
vendor. For real applications, you substitute in your vendor's device
files.  I build for SiliconLabs EFM32GG, so would replace occurrences in
./Makefile and *.mk of

```
ARMCM3.h
system_ARMCM3.c
startup_ARMCM3.c
arm_gcc.ld
```

with these

```
em_device.h
system_efm32gg.c
startup_efm32gg.c
efm32gg.ld
```

sdmaclean AT gmail.com

