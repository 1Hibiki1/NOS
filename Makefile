AS = nasm
AS_FLAGS = -f bin -i boot

BOOT_SRC_DIR = boot
BUILD_DIR = build

all: build_dir $(BUILD_DIR)/boot.bin

build_dir:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin
	cat $^ > $@

$(BUILD_DIR)/stage1.bin:
	$(AS) $(AS_FLAGS) $(BOOT_SRC_DIR)/stage1.asm -o $@

$(BUILD_DIR)/stage2.bin:
	$(AS) $(AS_FLAGS) $(BOOT_SRC_DIR)/stage2.asm -o $@

run:
	make clean
	make
	qemu-system-x86_64 -hda $(BUILD_DIR)/boot.bin

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.bin
