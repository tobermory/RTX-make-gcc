# Stuart Maclean, 2021.  See ./LICENSE.txt and ./README.md

# Here, we use a two-phase approach for including the RTX RTOS in your
# gcc/make embedded application.

# You first build libRTX.a from the appropriate RTX sources, obtained
# from github. This Makefile does the build.

# Second, you make local copies of RTX_Config.h and rtx_lib.c (both
# bundled with RTX). You edit RTX_Config.h to suit your application
# (thread count, tick freq, etc), and add rtx_lib.c (which #includes
# RTX_Config.h) to your application sources. Then link your app. This
# Makefile builds a few simple examples.

## Infrastructure, just to ensure this Makefile is leaner

include toolchain.mk

############################### CMSIS BUNDLE ##############################

# The 5.6.0 tag of the CMSIS_5 repo needs to be checked out for this
# Makefile to work (that is, we are building against 5.6.0), e.g.

# $ git clone https://github.com/ARM-software/CMSIS_5.git
# $ cd CMSIS_5
# $ git checkout 5.6.0
CMSIS_5_VERSION = 5.6.0

# Set this next variable to the path to CMSIS_5 above. Mine is at ../CMSIS_5
CMSIS_5_HOME = ../CMSIS_5

################################### CPU #################################

# We're building here for M3 by default, you could switch in e.g. M4
# (make CM4=1 or edit below).

ifdef CM4
include cm4.mk
else
include cm3.mk
endif

############################### DEVICE #############################

# DEVICE-specific settings mostly delegated to ./cm3.mk, ./cm4.mk, etc

# A generic ARM device is sufficient in order to build the RTX lib.
# You'll want your own vendor's DEVICE files to link your application
# of course.

DEVICE_OBJS = $(DEVICE_SRCS:.c=.o)

LDSCRIPT = $(DEVICE_HOME)/Source/GCC/gcc_arm.ld

############################# CORE, RTOS2, RTX #############################

CORE_HOME  = $(CMSIS_5_HOME)/CMSIS/Core

RTOS2_HOME = $(CMSIS_5_HOME)/CMSIS/RTOS2/

RTX_HOME   = $(RTOS2_HOME)/RTX

# For Cortex-M cpus, systick suffices as RTX tick source
# (though all funcs are WEAK, so you CAN override).
RTOS2_SRCS = os_systick.c

RTX_ALL_C_SRCS = $(shell cd $(RTX_HOME)/Source && ls *.c)

# We'll localize rtx_lib.c and build it with our application, so we do
# NOT include it in the rtx .a file (this FORCES us to locally
# configure RTX (via RTX_Config.h), which is what we want!
RTX_C_SRCS = $(filter-out rtx_lib.c, $(RTX_ALL_C_SRCS))

# RTX_Config.c contains WEAK impls of idle thread, error handler.
RTX_CONFIG_SRCS = RTX_Config.c

# .o file lists follow from corresponding .c, .S (the only .S is in cm3.mk)
RTOS2_OBJS = $(RTOS2_SRCS:.c=.o)

RTX_C_OBJS = $(RTX_C_SRCS:.c=.o)

RTX_ASM_OBJS = $(RTX_ASM_SRCS:.S=.o)

RTX_CONFIG_OBJS = $(RTX_CONFIG_SRCS:.c=.o)

RTX_OBJS = $(RTX_C_OBJS) $(RTX_ASM_OBJS) $(RTX_CONFIG_OBJS)

#################### Build Settings: VPATH, CPPFLAGS ##############

# run 'make flags' to inspect these

# Locates our example application sources (including rtx_lib_local.c)
VPATH += src/test/c

# Locates all RTX SRCS (C and ASM)
VPATH += $(RTX_HOME)/Source $(RTX_HOME)/Source/GCC

# Locates RTX_Config.c 
VPATH += $(RTX_HOME)/Config

# Locates os_systick.c 
VPATH += $(RTOS2_HOME)/Source

# Locates DEVICE_SRCS
VPATH += $(DEVICE_HOME)/Source

# Locates our faked/dummy RTE_Components.h (a Keil thing??)
CPPFLAGS += -I.

# EventRecorder (EVR) is another Keil concept, we skip it
CPPFLAGS += -DEVR_RTX_DISABLE=1

# Locates DEVICE_HEADER (see e.g. cm3.mk)
CPPFLAGS += -I$(DEVICE_HOME)/Include

# rtx_core_cm.h requires this macro
CPPFLAGS += -DCMSIS_device_header=\"$(DEVICE_HEADER)\"

# Pah! RTX/Source/rtx_lib.h and RTX/Include/rtx_evr.h both erroneously
# include RTX_Config.h.  If you remove those includes, all the RTX
# files we want to build will STILL build fine. And THAT would allow
# us to omit RTX/Config from CPPFLAGS. By having RTX/Config in
# CPPFLAGS, we have to deal with the issue of user application builds
# locating RTX/Config/RTX_Config.h in error. rtx_lib.c is the ONLY
# true includer of RTX_Config.h!!!  See 'localize' target later, and
# in the README.
CPPFLAGS += -I$(RTX_HOME)/Config

# Locates rtx_os.h
CPPFLAGS += -I$(RTX_HOME)/Include

# Locates os_tick.h, cmsis_os2.h
CPPFLAGS += -I$(RTOS2_HOME)/Include

# Locates core_cm3.h, etc
CPPFLAGS += -I$(CORE_HOME)/Include

LDLIBS += -lc -lnosys

#################################### Rules ################################

# Print out recipes only if V set (make V=1), else quiet to avoid clutter
ifndef V
ECHO=@
endif

# Our local examples that include, and thus link against, RTX
EXAMPLES = kernelStart

EXAMPLES_AXF = $(addsuffix .axf, $(EXAMPLES))

EXAMPLES_BIN = $(addsuffix .bin, $(EXAMPLES))

default: lib

lib: $(LIB)

$(LIB): $(RTX_OBJS) $(RTOS2_OBJS)
	@echo AR $(@F)
	$(ECHO)$(AR) cr $@ $^

examples: $(EXAMPLES_BIN)

############################## Pattern Rules ################################

# Overriding default patterns for inclusion of CPU_OPTIONS, which are
# a must. The arm-none-eabi toolchain can compile for a wide variety of
# cpus, and we have to tell it what we have.
%.o : %.c
	@echo CC $(<F)
	$(ECHO)$(CC) -c $(CPPFLAGS) $(CPU_OPTIONS) $(CFLAGS) $< $(OUTPUT_OPTION)

%.o : %.S
	@echo AS $(<F)
	$(ECHO)$(AS) $(CPU_OPTIONS) $(ASFLAGS) $< $(OUTPUT_OPTION)

# Note how even the linker needs CPU_OPTIONS too, else it picks up the
# wrong (non-Thumb) libc.a, crt.o, etc.
%.axf: %.o rtx_lib_local.o $(LIB) $(DEVICE_OBJS)
	@echo LD $(@F) = $(^F)
	$(ECHO)$(CC) $(LDFLAGS) $(CPU_OPTIONS) -T $(LDSCRIPT) \
	-Xlinker -Map=$*.map $^ $(LDLIBS) $(OUTPUT_OPTION)

%.bin: %.axf
	@echo OBJCOPY $(<F)
	$(ECHO)$(OBJCOPY) -O binary $< $@

############################ Localization ##################################

# Grab TWO files from the RTX source tree.  We then EDIT
# src/test/include/RTX_Config.h and COMPILE rtx_lib_local.c as part of
# our application (we do NOT need to edit it, just compile it).

# Why the local name 'rtx_lib_local.c'?  Well, if we didn't rename, a
# user could forget the 'make localize' step and an application would
# still build (we'd find rtx_lib.c and RTX_Config.h in the RTX source
# tree).  The localized name (whose .o result is a prerequisite of all
# our EXAMPLES) FORCES us to 'make localize', and THAT educates the user
# on how they configure an RTX kernel for their specific application,
# by editing the now-local RTX_Config.h.

localize:
	@echo Localizing RTX_Config.h, rtx_lib.c
	$(ECHO)[ -f src/test/c/rtx_lib_local.c ] || \
	cp $(RTX_HOME)/Source/rtx_lib.c src/test/c/rtx_lib_local.c
	$(ECHO)[ -f src/test/include/RTX_Config.h ] || \
	cp $(RTX_HOME)/Config/RTX_Config.h src/test/include

# This next way of localizing RTX_Config.h is more 'make-like' but
# ironically works SO well that the user is NOT forced to run 'make
# localize' at all, and we WANT this step to be apparent.
ifdef 0
local: src/test/c/rtx_lib_local.c src/test/include/RTX_Config.h

src/test/c/rtx_lib_local.c: $(RTX_HOME)/Source/rtx_lib.c
	cp $< $@

src/test/include/RTX_Config.h: $(RTX_HOME)/Config/RTX_Config.h
	cp $< $@
endif

# For rtx_lib_local.c (our local copy of rtx_lib.c) ONLY, we want to
# pick up our local RTX_Config.h, so we jam src/test/include at front
# of CPPFLAGS! We do not want to locate the 'vanilla' RTX_Config.h in
# the RTX source tree.

# Note also how we have to DEPEND on the .h file, ensuring a rebuild
# of the .c any time the .h changes. The .c itself NEVER changes!
rtx_lib_local.o : rtx_lib_local.c src/test/include/RTX_Config.h
	@echo CC $(<F)
	$(ECHO)$(CC) -c -I src/test/include $(CPPFLAGS) $(CPU_OPTIONS) $(CFLAGS) \
	$< $(OUTPUT_OPTION)

################################## CLEANUP ##############################

clean:
	$(RM) *.bin *.axf *.map *.a *.o

# Wipe out any localization step, to start over.  Warning, this wipes
# your edits to RTX_Config.h!
distclean: clean
	$(RM) src/test/c/rtx_lib_local.c src/test/include/RTX_Config.h

################################### MISC ##############################

# Inspect VPATH, CPPFLAGS, useful when things won't build
flags:
	@echo VPATH    $(VPATH)
	@echo CPPFLAGS $(CPPFLAGS)

.PHONY: default lib examples localize clean distclean flags

# eof
