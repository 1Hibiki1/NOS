UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
define sizeof
	stat -L -c %s $(1)
endef
endif
ifeq ($(UNAME), Darwin)
define sizeof
	stat -L -f %z $(1)
endef
endif

AS := nasm
AS_FLAGS := -i boot

BOOT_SRC_DIR := boot
BUILD_DIR = build
TOOLS_DIR = tools

BOOT_LOG_FILE = $(BUILD_DIR)/log.txt

define putsize
	echo $(@) >> $(BOOT_LOG_FILE)
	$(call sizeof, $(1)) >> $(BOOT_LOG_FILE)
	echo '' >> $(BOOT_LOG_FILE)
endef

all: NOS.img

NOS.img: build_dir tools $(BUILD_DIR)/boot.bin
	./tools/fatcreate.exe -l "NOS Boot" -b $(BUILD_DIR)/boot.bin -o NOS.img

build_dir:
	mkdir -p $(BUILD_DIR)

tools: $(TOOLS_DIR)/fatcreate.exe

$(TOOLS_DIR)/fatcreate.exe:
	gcc tools/fatcreate.c -o tools/fatcreate.exe

$(BUILD_DIR)/boot.bin: 	$(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin \
						$(BUILD_DIR)/stage3.bin
	cat $^ > $@

$(BUILD_DIR)/stage1.bin:
	$(AS) $(AS_FLAGS) -f bin $(BOOT_SRC_DIR)/stage1.asm -o $@
	$(call putsize, $@)

$(BUILD_DIR)/stage2.bin:
	$(AS) $(AS_FLAGS) -f bin $(BOOT_SRC_DIR)/stage2.asm -o $@
	$(call putsize, $@)

$(BUILD_DIR)/stage3.bin: $(BUILD_DIR)/stage3.o
	x86_64-elf-ld -o $@ -T boot/stage3.ld $^ --oformat binary
	$(call putsize, $@)

$(BUILD_DIR)/stage3.o: boot/stage3.c
	x86_64-elf-gcc -ffreestanding -c $< -o $@

run: NOS.img
	make clean
	make
	qemu-system-x86_64 -hda $<

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.bin *.img *.o

