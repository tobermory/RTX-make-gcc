# The parts of RTX (and ARM Device) specific to Cortex M4-FP CPU

# This file is included by the main ./Makefile

LIB = libRTX_CM4.a

RTX_ASM_SRCS = irq_cm4f.S

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM4

DEVICE_HEADER = ARMCM4_FP.h

DEVICE_SRCS = system_ARMCM4.c startup_ARMCM4.c

CPPFLAGS += -DARMCM4_FP

CPPFLAGS += -D__ARM_ARCH_7EM__=1

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc).  I am not at all sure about
# -mfloat-abi and -mfpu.
CPU_OPTIONS = -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

# eof

