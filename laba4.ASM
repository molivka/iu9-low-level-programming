assume cs: code, ds: data

data segment
dummy db 0Dh, 0Ah, '$'; перевод строки
digit_num db 11 ;количество разрядов без учёта знака
sign1 db 0; знак первого
num1 db 12, 12 dup(0); первое число
mass1 db 22, 22 dup(0); массив1 чисел
sign2 db 0; знак второго
num2 db 12, 12 dup(0); второе число
mass2 db 22, 22 dup(0); массив2 чисел
result db 22, 22 dup(0); ответ
massres db 22, 22 dup(0); массив ответа
error db 0; флаг ошибки
data ends

code segment
;reverse proc
 ;   ret
;reverse endp
to_int proc; в start пушим знак, массив, строку
    push bp
    mov bp, sp

    mov si, [bp+4]; строка
    mov di, [bp+6]; массив

    inc si; не учитываем максимальную длину строки
    xor cx, cx
    mov cl, [si];длина строки
    inc si;не учитываем фактическую длину строки
    cmp byte ptr [si], '-'; проверка на отрицательность
    jne pos
    dec cl; вычитаем 1, тк не учитываем знак
    mov si, [bp+8]; получаем доступ к переменной знак
    mov si, 1; устанавливаем флаг знака
    pos:
    inc di; пропускаем ячейку с длиной массива
    mov si, [bp+4]; обращение к строке
    inc si; пропуск длины
    add si, cx; чтобы идти с конца
	m:
	    xor dx, dx; чтобы не взять значения в dh
	    mov dl, [si]; последняя цифра строки
	    sub dl, '0'; приводим к числовому виду
	    cmp dl, 0
	    jb end_prog; если меньше нуля, то не цифра
	    cmp dl, 9
	    ja end_prog; если больше 9, то не цифра
	    mov [di], dl; записываем число в массив
	    add byte ptr [di], '0'; проверка
	    inc di
	    dec si
	loop m
;todo: дописать обработку ошибок
    ret
to_int endp

comp proc
    push bp
    mov bp, sp

    mov si, [bp+6]; 1 число
    mov di, [bp+4]; 2 число

    mov dx, 1; флаг, что первое число меньше
    xor cx, cx
    mov cl, [si]; длина массива
    add si, cx; идём с конца, тк число ревёрснуто
    add di, cx
    len_for:
        xor ax, ax
        xor bx, bx
        mov al, [si]; 1 число
        mov bl, [di]; 2 число
        dec si
        dec di
        cmp ax, bx
        jl endd; если 1 < 2
        cmp ax, bx
        jg end_loop; сесли 1 > 2
    loop len_for
    end_loop:
    mov dx, 0
    endd:
    pop bx; убираем со стека текущий адрес proc
	pop bx; сохраняем адрес возврата
	pop bp; достаём строку
	pop bp; достаём массив
	pop bp; достаём знак
	push bx ; кладём адрес возврата
    ret
comp endp

sub_unsign proc
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
    mov [si+1], al

    pop bx; убираем со стека текущий адрес proc
	pop bx; сохраняем адрес возврата
	pop bp; достаём первую строку
	pop bp; достаём вторую строку
	mov dx, offset result
    inc dx
	push dx ; кладём результат
	push bx ; кладём адрес возврата
    ret
sub_unsign endp

start:
        mov ax, data
		mov ds, ax

		mov dx, offset num1; чтение 1 строки
		xor ax, ax
		mov ah, 0Ah
		int 21h

		;перевод первой строки в массив
        mov dx, offset sign1
		push dx
		mov dx, offset mass1
		push dx
		mov dx, offset num1
		push dx
        call to_int

        mov dx, offset dummy ; добавление перевод строки
        mov ah, 09h
        int 21h

        mov dx, offset num2; чтение 2 строки
        xor ax, ax
        mov ah, 0Ah
        int 21h

        mov dx, offset sign2
		push dx
		mov dx, offset mass2
		push dx
		mov dx, offset num2
		push dx
        call to_int

        mov dx, offset dummy ; добавление перевод строки
        mov ah, 09h
        int 21h

		;пушаем в стек, чтобы произвести операцию сумма без знака
		mov dx, offset mass1
		push dx
		mov dx, offset mass2
		push dx
		mov dx, offset result
		push dx
        call sub_unsign
        pop dx
        mov ah, 09h
        int 21h

        ;пушаем в стек, чтобы произвести операцию сравнения без знака
        mov dx, offset mass1
		push dx
		mov dx, offset mass2
		push dx
        call comp
        pop dx
        cmp dx, 1
        jne end_prog; если не первой число меньше
        mov dx, offset mass1
        mov ah, 09h
        int 21h


end_prog:
		mov ah, 4ch
		int 21h
code ends
end start
