# The parts of CMSIS_5 specific to building RTX apps for Cortex M4
# CPUs, with FP.

# This file is included by the main ./Makefile, which must define
# CMSIS_5_HOME.

# See ./cm3.mk for more details.

LIB = RTX_CM4FP

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM4

DEVICE_SRCS = system_ARMCM4.c startup_ARMCM4.c

DEVICE_HEADER = ARMCM4FP.h

CPPFLAGS += -DARMCM4_FP

CPPFLAGS += -D__ARM_ARCH_7EM__=1

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc)

CPU_OPTIONS = -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

LDSCRIPT	= -T $(DEVICE_HOME)/Source/GCC/gcc_arm.ld

# eof

