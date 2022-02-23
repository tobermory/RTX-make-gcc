# Stuart Maclean: The RTX (RTOS2-compliant) RTOS, built by GCC/Make:
# Applications.

# Two hypothetical RTX-using applications, in app1.c and app2.c
# Each can have its own RTX configuration (OS_TICK_FREQ, etc) with
# no RTX edits, not even RTX_Config.h.

APPS = app1 app2

# GNU Toolchain for bare-metal ARM CPUs
AR = arm-none-eabi-ar
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

CMSIS_5_HOME = ../../CMSIS_5

ifdef CM4
include cm4.mk
else
include cm3.mk
endif

VPATH		+= $(DEVICE_HOME)/Source

DEVICE_OBJS = $(DEVICE_SRCS:.c=.o)

CORE_HOME	= $(CMSIS_5_HOME)/CMSIS/Core

RTOS2_HOME	= $(CMSIS_5_HOME)/CMSIS/RTOS2

RTX_HOME	= $(RTOS2_HOME)/RTX

VPATH		+= $(DEVICE_HOME)/Source

# ARMCMX.h
CPPFLAGS	+= -I $(DEVICE_HOME)/Include

# core_cmX.h
CPPFLAGS	+= -I $(CORE_HOME)/Include

# cmsis_os2.h
CPPFLAGS	+= -I $(RTOS2_HOME)/Include

# rtx_os.h, etc
CPPFLAGS	+= -I $(RTX_HOME)/Include

# RTX_Config.h
CPPFLAGS	+= -I $(RTX_HOME)/Config

CPPFLAGS	+= -DCMSIS_device_header=\"$(DEVICE_HEADER)\"

# Example .ld file from ARM.  Likely your vendor has their own,
# in addition to their own DEVICE_SRCS.

LDFLAGS		= $(CPU_OPTIONS) $(LDSCRIPT)

LDLIBS		+= -lc -lnosys 

ifndef V
ECHO=@
endif

APPS_AXF = $(addsuffix .axf, $(APPS))

APPS_BIN = $(addsuffix .bin, $(APPS))

# A .bin file is what is flashed to target board, so that is the build
# target, one per application. These are our default targets, so just
# 'make' builds them both = app1.bin, app2.bin.
default: $(APPS_BIN)

# Phony target allows 'make A' as a shorthand for 'make A.bin'
.PHONY: $(APPS)
$(APPS) : % : %.bin

# Per-application configuration of RTX runtime: tick freq, stack spaces, etc
app1_rtx_lib.o : CPPFLAGS += -DOS_TICK_FREQ=100

app2_rtx_lib.o : CPPFLAGS += -DOS_DYNAMIC_MEM_SIZE=16384 -DOS_TICK_FREQ=500

# Use a local copy of RTX's rtx_lib.c for each application, can then
# configure it as above. No edits of the new file are needed. Nor do
# we need edit RTX_Config.h, we do ALL 'RTX configuration per
# application' via -D options defined here.
app1_rtx_lib.c app2_rtx_lib.c: $(RTX_HOME)/Source/rtx_lib.c
	cp $^ $@

# Building each app's .axf file. Note the -L, -l access to rtx lib,
# as a pre-compiled library, in the parent dir.
$(APPS_AXF) : %.axf : %.o %_rtx_lib.o $(DEVICE_OBJS)
	@echo LD $(@F) = $(^F)
	$(ECHO)$(CC) $(LDFLAGS) $^ -L.. -l$(LIB) $(LDLIBS) $(OUTPUT_OPTION)

%.o : %.c
	@echo CC $(<F)
	$(ECHO)$(CC) -c $(CPPFLAGS) $(CPU_OPTIONS) $(CFLAGS) $< $(OUTPUT_OPTION)

%.bin: %.axf
	@echo OBJCOPY $(<F)
	$(ECHO)$(OBJCOPY) -O binary $< $@

.PHONY: clean
clean:
	$(RM) *.bin *.axf *.o *rtx_lib.c

.PRECIOUS: *.axf *.o

# eof

