[org 0x7c00]
[bits 16]

; some constants
STACK_BOTTOM        equ 0xa000
STAGE2_START_ADDR   equ 0x7e00
STAGE2_NSECTORS     equ 5

; 3 byte jmp to entrypoint and nop
jmp _start
NOP

;*********************************************
;    BPB
;*********************************************
; this will probably be overwritten by whatever 
; disk creation utility we're using
bpbOEM                  DB "NOS     "
bpbBytesPerSector:      DW 512
bpbSectorsPerCluster:   DB 1
bpbReservedSectors:     DW 1
bpbNumberOfFATs:        DB 2
bpbRootEntries:         DW 224
bpbTotalSectors:        DW 2880
bpbMedia:               DB 0xF0
bpbSectorsPerFAT:       DW 9
bpbSectorsPerTrack:     DW 18
bpbHeadsPerCylinder:    DW 2
bpbHiddenSectors:       DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber:          DB 0
bsUnused:               DB 0
bsExtBootSignature:     DB 0x29
bsSerialNumber:         DD 0xa0a1a2a3
bsVolumeLabel:          DB "TODOKETE   "
bsFileSystem:           DB "FAT32   "

; fat32 extended bpb
FAT32EBPB times 28 db 0

_start:
    ; disable interrupts
    cli

    ; setup stack
    mov sp, STACK_BOTTOM
    mov bp, sp

    ; init segment registers
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; read the second stage into memory at location STAGE2_START_ADDR
    mov ah, 0x2
    mov al, STAGE2_NSECTORS         ; n setors
    mov ch, 0                       ; cylinder/track
    mov cl, 2                       ; sector number
    mov dh, 0                       ; head number
    ; clear es
    xor bx, bx
    mov es, bx
    ; read
    mov bx, STAGE2_START_ADDR
    int 13h

    ; run stage 2
    jmp STAGE2_START_ADDR

    hlt

times 510-($-$$) db 0
dw 0xAA55
