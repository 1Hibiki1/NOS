%ifndef _CPU_ASM
%define _CPU_ASM

cpu_disable_interrupts:
    cli
    ret

cpu_enable_interrupts:
    sti
    ret

cpu_disable_NMI:
    in al, 0x70
    or al, 0x80
    out 0x70, al
    ret

cpu_enable_NMI:
    in al, 0x70
    and al, 0x7f
    out 0x70, al
    ret

%endif
