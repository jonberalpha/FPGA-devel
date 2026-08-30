###############################################################################
# Copyright (c) 2012 - 2020 Xilinx, Inc.  All rights reserved.
# SPDX-License-Identifier: MIT
###############################################################################


CC := arm-none-eabi-gcc
CC_FLAGS :=  
CFLAGS := 
ECFLAGS := 
LDFLAGS := 

BOARD	:= zc702
BSP_DIR	:= ../../zynq_fsbl/misc
DEPS	:= depends

c_SOURCES := $(wildcard *.c)
#c_SOURCES += $(BSP_DIR)/$(BOARD)/ps7_init.c
S_SOURCES := $(wildcard *.S)
s_SOURCES := $(wildcard *.s)
INCLUDES := $(wildcard *.h)
OBJS := $(patsubst %.c, %.o, $(c_SOURCES))
OBJS += $(patsubst %.S, %.o, $(S_SOURCES))
OBJS += $(patsubst %.s, %.o, $(s_SOURCES))
LSCRIPT := -Tlscript.ld

LIBS := libxil.a 
EXEC := qspi-flash-writer.elf

INCLUDEPATH := -I$(BSP_DIR)/ps7_cortexa9_0/include -I. -I$(BSP_DIR)/$(BOARD)
LIBPATH := $(BSP_DIR)/ps7_cortexa9_0/lib


ifeq "$(CC)" "arm-none-eabi-gcc"
AS=arm-none-eabi-gcc
# -Os plus function/data-sections + linker --gc-sections below: this app
# links the full XilFFs (FAT filesystem) + XQspiPs (QSPI driver, always
# also pulls in an unused RSA lib per LDFLAGS below), which don't fit the
# ~63.5KB app-RAM region (ps7_ram_1) at the template's default -O0 -g3.
# This is a one-shot provisioning tool, not something worth debugging
# on-target, so optimizing for size instead is the right tradeoff.
CFLAGS=-Wall -Os -c -fmessage-length=0 -ffunction-sections -fdata-sections
LINKER=arm-none-eabi-gcc
# No -lrsa: that's Xilinx's secure-boot signature verification library,
# unused by this plain, unsigned flash-writer.
LDFLAGS = -Wl,--gc-sections -Wl,--start-group,-lxil,-lgcc,-lc,--end-group -Wl,--start-group,-lxilffs,-lxil,-lgcc,-lc,--end-group
LD1FLAGS = -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -Wl,-build-id=none -Wl,-T -Wl,lscript.ld -L$(LIBPATH) -specs=../../zynq_fsbl/misc/Xilinx.spec
ECFLAGS = -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard
endif
ifeq "$(CC)" "armcc"
AS=armasm
LINKER=armlink 
CFLAGS += -c --c99 --wchar32
CC_FLAGS	+= --cpu=Cortex-A9 --fpu=VFPv3_FP16
LDFLAGS = --entry=_vector_table "$(LIBPATH)/libxil.a(*.o)" --no_search_dynamic_libraries --userlibpath=$(LIBPATH),. --library=xil,xilffs,rsa
LSCRIPT = --scatter="scatter.scat"
endif

all: $(EXEC)

$(EXEC): $(LIBS) $(OBJS) $(INCLUDES)
	$(LINKER) $(LD1FLAGS)  -o $@ $(OBJS) $(LDFLAGS)
	rm -rf $(OBJS)
	
	
$(LIBS): 
	make -C ../../zynq_fsbl/src libxil.a
	#echo "Copying BSP files"
	#cd ../../zynq_fsbl/src
	#$(BSP_DIR)/copy_bsp.sh $(BOARD) $(CC)
	#echo "Compiling bsp"
	#if [ $(CC) == "arm-none-eabi-gcc" ]; then \
		#make -C $(BSP_DIR) -k all "CC=arm-none-eabi-gcc" "AR=arm-none-eabi-ar" "C_FLAGS=-O2 -c" "EC_FLAGS=-g"; \
	#elif [ $(CC) == "armcc" ]; then \
        #make -C $(BSP_DIR) -k all "CC=armcc" "AR=armar" "C_FLAGS= -O2 -c" "EC_FLAGS=--debug --wchar32"; \
	#fi;
	#cd ../../hello_world/src

%.o:%.c
	$(CC) $(CC_FLAGS) $(CFLAGS) $(ECFLAGS) -c $< -o $@ $(INCLUDEPATH)

%.o:%.S
	if [ $(CC) == "arm-none-eabi-gcc" ]; then \
		$(AS) $(CC_FLAGS) $(CFLAGS) $(ECFLAGS) -c $< -o $@ $(INCLUDEPATH); \
	elif [ $(CC) == "armcc" ]; then \
        $(CC) $(INCLUDEPATH) -E -o fsbl_handoff.s fsbl_handoff.S; \
		$(AS) $(CC_FLAGS) -c fsbl_handoff.s -o fsbl_handoff.o $(INCLUDEPATH); \
		rm fsbl_handoff.s; \
	fi;
	
	
%.o:%.s
	$(AS) $(CC_FLAGS) $(CFLAGS) $(ECFLAGS) -c $< -o $@ $(INCLUDEPATH)

clean:
	rm -rf $(OBJS) $(BSP_DIR)/ps7_cortexa9_0 $(EXEC)


