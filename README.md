# Building Keil's RTX RTOS Using GCC+Make

On various forums I frequent, e.g.

* [Keil](https://community.arm.com/developer/tools-software/tools/f/keil-forum)

* [GNU Toolchain](https://community.arm.com/developer/tools-software/oss-platforms/f/gnu-toolchain-forum)

* [Silicon Labs](https://www.silabs.com/community/mcu/32-bit/forum)

the question sometimes pops up 'Can I build RTX with gcc/make', or
perhaps 'with CMake and GCC' ? The answer is yes, and this is how I do
it, on Linux at least. YMMV on other platforms.


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

The head of our
[main](https://github.com/tobermory/RTX-make-gcc/tree/main) branch is
currently the 5.8.0 tag.

## The Prerequisites

You need GNU Make and the arm-none-eabi toolchain.  Ensure both are on
your PATH. Author has v4.1 and v8.2.1 respectively, on Ubuntu
18.04LTS.

## The Preparation

First, grab RTX sources from github.  They are just one component of
the larger CMSIS_5 code bundle from ARM-software:

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

The files included in this repo that we will refer to in these
instructions are just:

```
Makefile
cm3.mk
cm4.mk
apps/Makefile
apps/cm3.mk
apps/cm4.mk
apps/app1.c
apps/app2.c
```

# The Build

The RTX 5.5.3 sources can be built mostly as a library (i.e. a .a
file) which can then be linked to your RTOS-using applications. We
describe such a build using gcc/make. We concentrate on builds for
Cortex M3 and M4 processors.

To configure the RTX parts of each application (tick frequency, thread
stacks, etc) requires including one RTX source file (`rtx_lib.c`) in
the build and link of each application. Again, we can do that using gcc/make.

We make no edits to ANY RTX source file, be it .c or .h, in the
library build and in application builds. 

## Building RTX As A Library

To build most of RTX 5.5.3 as a library requires we make decisions on two
RTX features at library-build time. These are

- object counters (OS_OBJ_MEM_USAGE)

- thread stack checking (OS_STACK_CHECK)

We make that decision in our Makefile for building the library:

```
CPPFLAGS += -DOS_OBJ_MEM_USAGE=0

CPPFLAGS += -DOS_STACK_CHECK=1
```

Edit as appropriate should you want/need different behavior.

The library build takes these files (in-place, no copying):

```
CMSIS_5/CMSIS/RTOS2/Source/os_systick.c
CMSIS_5/CMSIS/RTOS2/RTX/Config/RTX_Config.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_delay.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_evflags.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_evr.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_kernel.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_memory.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_mempool.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_msgqueue.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_mutex.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_semaphore.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_system.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_thread.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/rtx_timer.c
CMSIS_5/CMSIS/RTOS2/RTX/Source/GCC/irq_armv7.S
```

and produces, via a single make invocation, a .a file:

```
$ make
AR libRTX_CM3.a
```

By default, each gcc invocation is suppressed.  To see those in full,
supply a V option:

```
$ make clean
$ make V=1
```

The library built here targets a Cortex M3. To build for CM4 (hard FP)
instead:

```
$ make clean
$ make CM4=1
AR libRTX_CM4FP.a
```

The main Makefile includes cm3.mk, cm4.mk to tailor the gcc
invocations.  Adapt to suit other CPUs.

See the [Makefile](Makefile) for more commentary.

## Building Applications That Use The Library

We include two trivial applications.  They are placed in a
sub-directory 'apps' to convey the intent that the library can be
built independently of applications. The Makefile in the 'apps'
directory in no way depends on the Makefile described thus far (the one
that builds the lib):

```
$ cd apps

$ ls *.c
app1.c app2.c

$ cat Makefile
```
Edit the Makefile to fix the line:

```
CMSIS_5_HOME = SOME_HOME_FOR_CMSIS_5/CMSIS_5
```
as you did for the library build Makefile above.

As stated above, one RTX source file needs compiling with each
application.  This is `rtx_lib.c`, and in combination with the RTX
header `RTX_Config.h`, it allows for RTX configuration of any particular
application.

Luckily, `RTX_Config.h` is written in such a way that RTX can be
configured without any need to edit it.  We use that fact to our
advantage.

First, we want a make target that can associate a 'fresh copy' of
`rtx_lib.c` with each application, and we have that for our two
examples:

```
app1_rtx_lib.c app2_rtx_lib.c: $(RTX_HOME)/Source/rtx_lib.c
	cp $^ $@
```

Without an `rtx_lib.o` for each application, you run the risk of a
shared `rtx_lib.o` being linked to BOTH applications, and it may be
right for one but wrong for the other.

If you have just a single application in your project, disregard this
and just use `rtx_lib.c` in-place via VPATH. 

Next, we want to configure each application's RTX runtime
requirements, individually.  We can do this via GNU make's
'target-specific variable values' (6.11 GNU make manual):

```
app1_rtx_lib.o : CPPFLAGS += -DOS_TICK_FREQ=100

app2_rtx_lib.o : CPPFLAGS += -DOS_DYNAMIC_MEM_SIZE=16384 -DOS_TICK_FREQ=500
```

Finally, we need a way to link each application into something
runnable on a target board.  The recipe will use the RTX library built
above:

```
$(APPS_AXF) : %.axf : %.o %_rtx_lib.o $(DEVICE_OBJS)
	@echo LD $(@F) = $(^F)
	$(ECHO)$(CC) $(LDFLAGS) $^ -L.. -l$(LIB) $(LDLIBS) $(OUTPUT_OPTION)
```

which is a terse way of saying this:

```
app1.axf : app1.o app1_rtx_lib.o system_ARMCM3.o startup_ARMCM3.o
	...

app2.axf : app2.o app2_rtx_lib.o system_ARMCM3.o startup_ARMCM3.o
	...
```

The applications are now ready to be built, and we haven't edit ANY
RTX sources. The default make target in the apps directory builds a
.bin file for each application, ready to be flashed to a target board:

```
$ make
$ ls *.bin
app1.bin app2.bin
```

To see the build in full, perhaps for one app only:

```
$ make clean
$ make app1 V=1
...
```

See the [apps/Makefile](apps/Makefile) for more details.

Like the library build, we can also build the example apps for CM4
instead of CM3. Ensure the CM4 lib is built first:

```
$ cd ..
$ make clean
$ make CM4=1
$ cd apps
$ make clean
$ make CM4=1
```

Like the library Makefile, the apps Makefile makes use of (its own)
cm3.mk, cm4.mk to direct the build to a certain processor.

## Other Devices

The application builds here (app*.bin) used the 'Device' files
`system_ARMCM3.c` and `startup_ARMCM3.c`, together with the linker
script `gcc_arm.ld`. We also defined the Device Header to be
`ARMCM3.h`. See the app/cm3.mk (and cm4.mk) for details.

These files describe the most basic of Cortex-M3 cpus, just the core
processor.  There are of course no peripherals, since these vary by
vendor. For real applications, you substitute in your vendor's device
files.  I build for SiliconLabs EFM32GG, so would replace occurrences
in *.mk of these:

```
ARMCM3.h
system_ARMCM3.c
startup_ARMCM3.c
arm_gcc.ld
```

with these:

```
em_device.h
system_efm32gg.c
startup_efm32gg.c
efm32gg.ld
```

sdmaclean AT gmale

