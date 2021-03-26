# The parts of RTX (and ARM Device) specific to Cortex M3 CPU

# This file is included by the main ./Makefile

LIB = libRTX_CM3.a

RTX_ASM_SRCS = irq_cm3.S

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM3

DEVICE_HEADER = ARMCM3.h

DEVICE_SRCS = system_ARMCM3.c startup_ARMCM3.c

CPPFLAGS += -D__CORTEX_M3

CPPFLAGS += -D__ARM_ARCH_7M__=1

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc)
CPU_OPTIONS = -mcpu=cortex-m3

# eof
