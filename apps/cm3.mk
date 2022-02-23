# The parts of CMSIS_5 specific to building RTX apps for Cortex M3 CPU.

# This file is included by the main ./Makefile, which must define
# CMSIS_5_HOME.

# The 'device' we have chosen here is a generic 'ARMCM3' as defined by
# ARM.  That device serves as a vehicle for building and linking
# binaries for a CM3 target.

# In practice, your vendor will supply a set of files complementary to
# the ARMCM3 device, and you would use THOSE here.  I build for
# Silicon Labs EFM32GG microcontrollers, so my files would be

# DEVICE_SRCS	= system_efm32gg.c startup_efm32gg.c
# DEVICE_HEADER	= em_device.h
# LDSCRIPT		= em32gg.ld

LIB = RTX_CM3

DEVICE_HOME = $(CMSIS_5_HOME)/Device/ARM/ARMCM3

DEVICE_SRCS = system_ARMCM3.c startup_ARMCM3.c

DEVICE_HEADER = ARMCM3.h

CPPFLAGS += -DARMCM3

CPPFLAGS += -D__ARM_ARCH_7M__=1

# Set this mandatory CC setting here, NOT in CFLAGS, which the user
# likes to control (warnings,debug,etc)

CPU_OPTIONS = -mcpu=cortex-m3

LDSCRIPT	= -T $(DEVICE_HOME)/Source/GCC/gcc_arm.ld

# eof
