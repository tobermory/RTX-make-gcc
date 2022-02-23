# The parts of RTX (and ARM Device) specific to Cortex M3 CPU

# This file is included by the main ./Makefile

LIB = libRTX_CM3.a

RTX_ASM_SRCS = irq_armv7m.S

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM3

DEVICE_HEADER = ARMCM3.h

DEVICE_SRCS = system_ARMCM3.c startup_ARMCM3.c

CPPFLAGS += -DARMCM3

CPPFLAGS += -D__ARM_ARCH_7M__=1

TO_LOCALIZE = $(RTX_ASM_SRCS)

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc)
CPU_OPTIONS = -mcpu=cortex-m3

# eof
