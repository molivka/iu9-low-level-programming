assume cs: code, ds: data

data segment
dummy db 0Dh, 0Ah, '$'; перевод строки
digit_num db 90 ;количество разрядов без учёта знака
sign1 db 0; знак первого
num1 db 12, 12 dup(0); первое число
mass1 db 22, 22 dup(0); массив1 чисел
sign2 db 0; знак второго
num2 db 12, 12 dup(0); второе число
mass2 db 22, 22 dup(0); массив2 чисел
result db 23, 22 dup(0); ответ + знак
data ends

code segment
;reverse proc
 ;   ret
;reverse endp

sum_unsign proc
    push bp;сохраняем адрес начала
    mov bp, sp

    mov si, [bp+6];доступ ко второму массиву
    mov di, [bp+8];доступ к первому массиву
    xor cx, cx
    mov cl, [si];кол-во цифр числа
    add si, 1; пропускаем ячейку с длинной
    add di, 1
    for:
        xor ax, ax
        mov al, [si]
        add al, [di]
        mov bl, 10
        div bl
        mov [di], ah
        add [di+1], al
        inc si
        inc di
    loop for

    mov si, [bp+4];доступ к строке-результату
    mov di, [bp+8];доступ к первому массиву
    mov cl, [di]
    inc si; пропуск ячейки с размером
    inc di
    for_to_int:
        xor ax, ax
        mov al, [di]
        add al, '0'
        mov [si], al
        inc si
        inc di
    loop for_to_int
    mov al, '$'
    mov [di+1], al

    pop bx; убираем со стека текущий адрес proc
	pop bx; сохраняем адрес возврата
	pop bp; достаём первую строку
	pop bp; достаём вторую строку
	mov dx, offset result
    inc dx
	push dx ; кладём результат
	push bx ; кладём адрес возврата
    ret
sum_unsign endp


start:
        mov ax, data
		mov ds, ax

		mov dx, offset num1; чтение 1 строки
		xor ax, ax
		mov ah, 0Ah
		int 21h

        ;перевод символов 1 строки в числа
        mov si, 1; не учитываем максимальную длину
        xor cx, cx
        mov cl, num1[si];длина строки
        mov di, cx; для заполнения массива чисел символами строки в обратном порядке
        add di, 1
        add si, 1;не учитываем фактическую длину строки
        cmp num1[si], '-'; проверка на отрицательность
        jne pos1
        sub cl, 1; вычетаем 1, тк не учитываем знак
        mov sign1, 1; устанавливаем флаг знака
        pos1:
        mov si, 1; тк это индекс в массиве + 1 с учётом ячейки на длину
		m1:
		    xor dx, dx; чтобы не взять значения в dh
		    mov dl, num1[di]; последняя цифра строки
		    sub dl, '0'; приводим к числовому виду
		    cmp dl, 0
		    jb end_prog; если меньше нуля, то не цифра
		    cmp dl, 9
		    ja end_prog; если больше 9, то не цифра
		    mov mass1[si], dl; записываем число в массив в обратном порядке
		    ;add mass1[si], '0'
		    inc si
		    dec di
		loop m1

        mov dx, offset dummy ; добавление перевод строки
        mov ah, 09h
        int 21h

        mov dx, offset num2; чтение 2 строки
        xor ax, ax
        mov ah, 0Ah
        int 21h

        ;перевод символов 2 строки в числа
        mov si, 1; не учитываем максимальную длину
        xor cx, cx
        mov cl, num2[si];длина строки
        mov di, cx; для заполнения массива чисел символами строки в обратном порядке
        add di, 1
        add si, 1;не учитываем фактическую длину строки
        cmp num2[si], '-'; проверка на отрицательность
        jne pos2
        sub cl, 1; вычетаем 1, тк не учитываем знак
        mov sign2, 1; устанавливаем флаг знака
        pos2:
        mov si, 1; тк это индекс в массиве + 1 с учётом ячейки на длину
		m2:
		    xor dx, dx; чтобы не взять значения в dh
		    mov dl, num2[di]; последняя цифра строки
		    sub dl, '0'; приводим к числовому виду
		    cmp dl, 0
		    jb end_prog; если меньше нуля, то не цифра
		    cmp dl, 9
		    ja end_prog; если больше 9, то не цифра
		    mov mass2[si], dl; записываем число в массив в обратном порядке
		    ;add mass2[si], '0'
		    inc si
		    dec di
		loop m2

        mov dx, offset dummy ; добавление перевод строки
        mov ah, 09h
        int 21h

		;пушаем в стек, чтобы произвести операции
		mov dx, offset mass1
		push dx
		mov dx, offset mass2
		push dx
		mov dx, offset result
		push dx
        call sum_unsign
        pop dx
        mov ah, 09h
        int 21h


end_prog:
		mov ah, 4ch
		int 21h
code ends
end start
