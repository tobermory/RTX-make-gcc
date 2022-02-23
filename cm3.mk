# The parts of RTX (and ARM Device) specific to Cortex M3 CPU

# This file is included by the main ./Makefile

LIB = libRTX_CM3.a

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM3

DEVICE_HEADER = ARMCM3.h

CPPFLAGS += -DARMCM3

CPPFLAGS += -D__ARM_ARCH_7M__=1

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc)
CPU_OPTIONS = -mcpu=cortex-m3

# eof
