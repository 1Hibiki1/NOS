ENTRY(stage3_start)

SECTIONS {
    /* Set the base address of the program in memory */
    . = 0xA000;

    /* The bootloader code */
    .text : AT(0xA000) {
        *(.text)
    }

    /* Read-only data (constants, etc.) */
    .rodata : AT(0xA000 + SIZEOF(.text)) {
        *(.rodata*)
    }

    /* Initialized data (global variables with initial values) */
    .data : AT(0xA000 + SIZEOF(.text) + SIZEOF(.rodata)) {
        *(.data*)
    }

    /* Uninitialized data (BSS) */
    .bss : AT(0xA000 + SIZEOF(.text) + SIZEOF(.rodata) + SIZEOF(.data)) {
        *(COMMON)
        *(.bss)
    }

    /* Make sure the total program size is aligned to a page size (4KB) */
    /DISCARD/ : {
        *(.comment)
        *(.eh_frame)
    }
}
