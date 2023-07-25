; thanks, chatgpt
screen_puts:
    ; Input:
    ;   DS:SI points to the null-terminated string to be printed
    ; Output:
    ;   None
    ; Clobbers:
    ;   AH, AL, BH, BL, CX, DX, SI, DI

    pusha               ; Save registers

    mov ah, 0x0E        ; BIOS teletype function
.puts_loop:
    lodsb               ; Load the next character from [DS:SI] into AL and increment SI
    test al, al         ; Check if the character is null (end of string)
    jz .puts_done       ; If null, we're done printing
    int 0x10            ; Print the character in AL
    jmp .puts_loop      ; Continue looping for the next character

.puts_done:
    popa                ; Restore registers
    ret

screen_print_line:
    call screen_puts
    push ax

    ; print \n\r
    mov ah, 0xE
    mov al, 0xA
    int 0x10
    mov ah, 0xE
    mov al, 0xD
    int 0x10

    pop ax
    ret
