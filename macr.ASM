str_in macro string

    mov dx, offset string; чтение 1 строки
	xor ax, ax
	mov ah, 0Ah
	int 21h

    mov dx, 10 ; добавление перевод строки
    mov ah, 02h
    int 21h

endm

str_out macro string

    xor ax, ax
    mov dx, offset string
    add dx, 2
	mov ah, 09h
	int 21h

    mov dx, 10 ; добавление перевод строки
    mov ah, 02h
    int 21h

endm

str_find macro string, symbol
    mov dx, 0; счётчик
    mov si, offset string; адрес строки
    inc si
    xor cx, cx
    mov cl, [si]; получаем длину
    inc si
    mov di, offset symbol
    add di, 2
    mov bl, [di]; получаем символ
    m:
        xor ax, ax
        mov al, [si]
        cmp al, bl
        jne not_eq
        inc dx
        not_eq:
        inc si
    loop m
endm