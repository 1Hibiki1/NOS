%ifndef _CPU32_ASM
%define _CPU32_ASM

cpu32_disable_interrupts:
    cli
    ret

cpu32_check_cpuid:
    ; the FLAGS register. If we can flip it, CPUID is available.
 
    ; Copy FLAGS in to EAX via stack
    pushfd
    pop eax
 
    ; Copy to ECX as well for comparing later on
    mov ecx, eax
 
    ; Flip the ID bit
    xor eax, 1 << 21
 
    ; Copy EAX to FLAGS via the stack
    push eax
    popfd
 
    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax
 
    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the ID bit
    ; back if it was ever flipped).
    push ecx
    popfd
 
    ; Compare EAX and ECX. If they are equal then that means the bit wasn't
    ; flipped, and CPUID isn't supported.
    xor eax, ecx
    jz cpu32_check_cpuid_false
    clc
    ret
cpu32_check_cpuid_false:
    stc
    ret


cpu32_check_long_mode:
    mov eax, 0x80000000     ; Set the A-register to 0x80000000.
    cpuid                   ; CPU identification.
    cmp eax, 0x80000001     ; Compare the A-register with 0x80000001.
    jb cpu32_check_long_mode_false       ; It is less, there is no long mode.

    mov eax, 0x80000001     ; Set the A-register to 0x80000001.
    cpuid                   ; CPU identification.
    test edx, 1 << 29       ; Test if the LM-bit, which is bit 29, is set in the
                            ; D-register.
    jz cpu32_check_long_mode_false
    clc
    ret
cpu32_check_long_mode_false:
    stc
    ret


%endif
