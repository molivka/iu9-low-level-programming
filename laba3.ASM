assume cs: code, ds: data

data segment
dummy db 0Dh, 0Ah, '$'
string1 db 100, 100 dup ('$')
string2 db 100, 100 dup('$')
data ends

code segment
strcat proc
    push bp; сохраняем указатель на адрес
	mov bp, sp; текущий указатель
	mov di, [bp+4] ; доступ ко второй строке
	add di, 2; не учитываем длину
	mov si, [bp+6]; доступ к первой сторке
	add si, 2; не учитываем длину
    xor ax, ax
	find_len_string1:
	    mov al, [si]
	    cmp al, '$'
	    je end_find_len_string1
	    inc si
        jmp find_len_string1

    end_find_len_string1:
    dec si
    mov cx, 0
    xor ax, ax
    find_len_string2:
        mov al, [di]
    	cmp al, '$'
    	je end_find_len_string2
    	inc di
    	inc cx
    	jmp find_len_string2

    end_find_len_string2:
    xor ax, ax
    mov di, [bp+4]; доступ ко второй строке
    add di, 2;
	m1:
	    mov al, [di]
	    mov [si], al
	    inc si
	    inc di
	loop m1
	pop bx; убираем со стека текущий адрес proc
	pop bx; сохраняем адрес возврата
	pop bp; достаём первую строку
	pop bp; достаём вторую строку
	mov dx, offset string1; strcat возвращает указатель на первую строку
	add dx, 2; не учитываем длин
	push dx ; кладём результат
	push bx ; кладём адрес возврата
	ret
strcat endp

start:
        mov ax, data
		mov ds, ax

		mov dx, offset string1; чтение 1 строки
		xor ax, ax
		mov ah, 0Ah
		int 21h

		mov dx, offset dummy ; добавление перевод строки(?)
		mov ah, 09h
		int 21h

		mov dx, offset string2; чтение 2 строки
        xor ax, ax
        mov ah, 0Ah
        int 21h

        mov dx, offset dummy; добавление перевод строки
        mov ah, 09h
    	int 21h

		mov dx, offset string1; кладём в стек первую строку
		push dx
		mov dx, offset string2; кладём в стек вторую строку
		push dx
		call strcat

		pop dx ; извлекаем со стека возвращённое значение
        mov ah, 09h
        int 21h

		mov ah, 4ch
		int 21h
code ends
end start
