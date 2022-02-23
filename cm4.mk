# The parts of RTX (and ARM Device) specific to Cortex M4 CPU.

# Here, we'll assert a CM4 WITH FP, your CM4 config may vary.

# This file is included by the main ./Makefile

LIB = libRTX_CM4FP.a

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM4

DEVICE_HEADER = ARMCM4_FP.h

CPPFLAGS += -DARMCM4_FP

CPPFLAGS += -D__ARM_ARCH_7EM__=1

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc)

CPU_OPTIONS = -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

# eof
