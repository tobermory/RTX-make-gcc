# GNU Toolchain for bare-metal ARM CPUs
AR = arm-none-eabi-ar
CC = arm-none-eabi-gcc

# Git clone 'https://github.com/ARM-software/CMSIS_5.git'
# and checkout tag '5.8.0'. 
CMSIS_5_HOME = ../CMSIS_5

# By default, we'll build for a Cortex M3 cpu, but CM4 is an option
# 'make CM4=1'.
ifdef CM4
include cm4.mk
else
include cm3.mk
endif

# Various components within the CMSIS_5 distro (cmX.mk defines one more)
CORE_HOME  = $(CMSIS_5_HOME)/CMSIS/Core
RTOS2_HOME = $(CMSIS_5_HOME)/CMSIS/RTOS2
RTX_HOME   = $(RTOS2_HOME)/RTX

# Locate the RTX sources via VPATH, no need to copy them

# os_systick.c
VPATH += $(RTOS2_HOME)/Source

# RTX_Config.c
VPATH += $(RTX_HOME)/Config

# rtx_thread.c, etc
VPATH += $(RTX_HOME)/Source

# irq_armv7m.S (used both the CM3 and CM4 builds)
VPATH += $(RTX_HOME)/Source/GCC

# Locate the RTX headers via CPFLAGS

# ARMCMX.h
CPPFLAGS += -I $(DEVICE_HOME)/Include

# core_cmX.h
CPPFLAGS += -I $(CORE_HOME)/Include

# cmsis_os2.h
CPPFLAGS += -I $(RTOS2_HOME)/Include

# rtx_os.h, etc
CPPFLAGS += -I $(RTX_HOME)/Include

# RTX_Config.h
CPPFLAGS += -I $(RTX_HOME)/Config

# Dummy RTE_Components.h, defined here and empty
CPPFLAGS += -I.

CPPFLAGS += -DCMSIS_device_header=\"$(DEVICE_HEADER)\"

# Important: Our build of RTX as a library makes the decision that
# object counters are NOT needed, but thread stack overflow checking
# IS. Thus, ALL apps linking to this library are configured that way.

CPPFLAGS += -DOS_OBJ_MEM_USAGE=0

CPPFLAGS += -DOS_STACK_CHECK=1

# The sources that comprise our library build of RTX

RTOS2_SRCS		= os_systick.c

RTX_ALL_C_SRCS	= $(shell cd $(RTX_HOME)/Source && ls *.c)

RTX_ALL_C_SRCS	+= RTX_Config.c

# rtx_lib.c is copied into applications and compiled there, so omit here
RTX_C_SRCS		= $(filter-out rtx_lib.c, $(RTX_ALL_C_SRCS))

RTX_ASM_SRCS	= irq_armv7m.S

RTOS2_OBJS		= $(RTOS2_SRCS:.c=.o)

RTX_C_OBJS		= $(RTX_C_SRCS:.c=.o)

RTX_ASM_OBJS	= $(RTX_ASM_SRCS:.S=.o)

RTX_OBJS		= $(RTX_C_OBJS) $(RTX_ASM_OBJS)

# 'make V=1' shows CC cmdlines, else suppress
ifndef V
ECHO=@
endif

# LIB file name itself defined in cmX.mk
default: $(LIB)

$(LIB): $(RTOS2_OBJS) $(RTX_OBJS)
	@echo AR $(@F)
	$(ECHO)$(AR) cr $@ $^

%.o : %.c
	@echo CC $(<F)
	$(ECHO)$(CC) -c $(CPPFLAGS) $(CPU_OPTIONS) $(CFLAGS) $< $(OUTPUT_OPTION)

%.o : %.S
	@echo AS $(<F)
	$(ECHO)$(CC) -c $(CPPFLAGS) $(CPU_OPTIONS) $(ASFLAGS) $< \
	$(OUTPUT_OPTION)

.PHONY: clean
clean:
	$(RM) *.a *.o

# eof
