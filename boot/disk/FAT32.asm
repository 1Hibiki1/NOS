; REDUNDANT, MOVE TO C

bytes_per_sector dw 0
n_reserved_sectors dw 0
n_fat db 0
n_sectors_per_track dw 0
n_total_sectors dd 0
n_sectors_per_fat dd 0

; inputs: 
;   rax = start address of loaded bpb in memory
; outputs:
;   none
FAT32_load_info:
    push rbx

    mov bx, WORD [rax + 11]
    mov WORD [bytes_per_sector], bx

    mov bx, WORD [rax + 14]
    mov WORD [n_reserved_sectors], bx

    mov bl, BYTE [rax + 16]
    mov BYTE [n_fat], bl

    mov bx, WORD [rax + 24]
    mov WORD [n_sectors_per_track], bx

    ; TODO: dont assume diak has more than 65535 sectors
    ; this reads from Large sector count, which is only set if 
    ; disk has more than 65535 sectors
    mov ebx, DWORD [rax + 32]
    mov DWORD [n_total_sectors], ebx

    ; extended bpb stuffs
    mov ebx, DWORD [rax + 36]
    mov DWORD [n_sectors_per_fat], ebx

    pop rbx
    ret
