[org 0x7e00]
[bits 16]

; jump to "main"
jmp stage2_start

; constants
PML4T_START equ 0x1000
PROT_MODE_STACK equ 0x90000

; includes
%include "cpu/cpu.asm"
%include "cpu/gdt.asm"
%include "cpu/a20.asm"
%include "screen/screen16.asm"

; strings
DONE_STR            db 'done', 0
DISABLE_INT_MSG     db 'diabling interrupts...', 0
DISABLE_NMI_MSG     db 'diabling NMI...', 0
ENABLE_A20_MSG      db 'enabling A20...', 0
LGDT_MSG    db 'loading gdt...', 0

; stage 2 entrypoint
stage2_start:
    ; disable interrupts
    call cpu_disable_interrupts

    ; disable nmi
    call cpu_disable_NMI

    ; enable a20
    call enable_a20
    jc A20_fail

    ; load gdt
    lgdt [gdt_descriptor]

    ; enable protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; jump to PM code
    jmp CODE_SEG:protected_mode_start

A20_fail_msg db 'could not enable A20 line', 0
A20_fail:
    mov si, A20_fail_msg
    call screen_puts
    hlt


; protected mode code
[bits 32]

; includes
%include "cpu/cpu32.asm"
%include "cpu/gdt64.asm"

; pm entrypoint
protected_mode_start:
    call cpu32_disable_interrupts

    ; init segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; setup stack
    mov ebp, PROT_MODE_STACK
    mov esp, ebp

    ; check if we have cpuid
    call cpu32_check_cpuid
    jc no_cpuid

    ; check if we have long mode
    call cpu32_check_long_mode
    jc no_long_mode

    ; setup paging
    mov edi, PML4T_START    ; Set the destination index to 0x1000.
    mov cr3, edi            ; Set control register 3 to the destination index.
    xor eax, eax            ; Nullify the A-register.
    mov ecx, 4096           ; Set the C-register to 4096.
    rep stosd               ; Clear the memory.
    mov edi, cr3            ; Set the destination index to control register 3.

    mov DWORD [edi], 0x2003      ; destination index  0x2003.
    add edi, 0x1000              ; Add 0x1000 to the destination index.
    mov DWORD [edi], 0x3003      ; destination index 0x3003.
    add edi, 0x1000              ; Add 0x1000 to the destination index.
    mov DWORD [edi], 0x4003      ; destination index 0x4003.
    add edi, 0x1000              ; Add 0x1000 to the destination index.

    mov ebx, 0x00000003
    mov ecx, 512
    
    ; initialize page tables
.SetEntry:
    mov DWORD [edi], ebx         ; destination index
    add ebx, 0x1000              ; Add 0x1000 to the B-register.
    add edi, 8                   ; Add eight to the destination index.
    loop .SetEntry               ; Set the next entry.

    mov eax, cr4                 ; Set the A-register to control register 4.
    or eax, 1 << 5               ; Set PAE-bit, which is the 6th bit (bit 5).
    mov cr4, eax                 ; Set control register 4 to the A-register.
    ; end initialize page tables

    ; TODO: check for pml5

    mov ecx, 0xC0000080          ; Set EFER MSR.
    rdmsr                        ; Read from the model-specific register.
    or eax, 1 << 8               ; Set the LM-bit which is the 9th bit (bit 8).
    wrmsr                        ; Write to the model-specific register.

    mov eax, cr0                 ; Set the A-register to control register 0.
    or eax, 1 << 31              ; Set PG-bit, which is the 32nd bit (bit 31).
    mov cr0, eax                 ; Set control register 0 to the A-register.

    ; load 64 bit gdt
    lgdt [GDT64.Pointer]

    ; jump to 64 bit code
    jmp GDT64.Code:long_mode_start

    hlt

no_cpuid:
    ; TODO: have an actual print function
    mov BYTE [0xb8000], 'n'
    mov BYTE [0xb8002], 'c'
    hlt

no_long_mode:
    mov BYTE [0xb8000], 'n'
    mov BYTE [0xb8002], 'l'
    hlt


; long mode code
[bits 64]

%include "disk/ata.asm"

long_mode_start:
    ; initialize segment registers
    mov ax, GDT64.Data            ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.

    ; clear screen, blue bg/ white fg
    mov rdi, 0xB8000              ; Set the destination index to 0xB8000.
    mov rax, 0x1F201F201F201F20   ; Set the A-register to 0x1F201F201F201F20.
    mov rcx, 500                  ; Set the C-register to 500.
    rep stosq                     ; Clear the screen.

; TEMPORARY TEST CODE AHEAD

    ; read the first sector of disk at 1mb
    mov eax, 0
    mov cl, 1
    mov rdi, 0x100000
    call ata_lba_read

    ; print some number of characters we read starting at offset 3
    ; which is BPB OEM ID string
    mov rcx, 3
    mov rdx, 0
.loop
    cmp rcx, 10
    je .loop_done

    mov al, BYTE [0x100000 + rcx]
    mov BYTE [0xB8000 + rdx], al
    inc rcx
    add rdx, 2
    jmp .loop

.loop_done
    hlt
