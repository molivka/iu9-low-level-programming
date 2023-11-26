assume cs: code, ds: data

data segment
dummy db 0Dh, 0Ah, '$'; перевод строки
digit_num db 90 ;количество разрядов без учёта знака
sign1 db 0; знак первого
num1 db 12, 12 dup('0'); первое число
mass1 db 22, 22 dup('0'); массив1 чисел
sign2 db 0; знак второго
num2 db 12, 12 dup('0'); второе число
mass2 db 22, 22 dup('0'); массив2 чисел
result db 22, 22 dup('0'); ответ
data ends

code segment
;reverse proc
 ;   ret
;reverse endp

;sum_unsign proc
 ;   ret
;sum_unsign endp


start:
        mov ax, data
		mov ds, ax

		mov dx, offset num1; чтение 1 строки
		xor ax, ax
		mov ah, 0Ah
		int 21h

        mov si, 1
        xor cx, cx
        mov cl, num1[si]
        add si, 1;тк есть длина строки
		mov di, 15; для заполнения массива чисел в обратном порядке 2 - на длину
		m1:
		    xor dx, dx; чтобы не взять значения в dh
		    mov dl, num1[si]
		    sub dl, '0'; приводим к числовому виду
		    cmp dl, 0
		    jb end_prog; если меньше нуля, то не цифра
		    cmp dl, 9
		    ja end_prog; если больше 9, то не цифра
		    mov mass1[di], dl; записываем число в массив в обратном порядке
		    inc si
		    dec di
		loop m1

        mov dx, offset mass1
        add dx, 2
        mov ah, 09h
        int 21h


		;mov dx, offset num2; чтение 2 строки
        ;xor ax, ax
        ;mov ah, 0Ah
        ;int 21h

        ;mov dx, offset dummy; добавление перевод строки
        ;mov ah, 09h
    	;int 21h

		;mov dx, offset num1; кладём в стек первую строку
		;push dx
		;mov dx, offset num2; кладём в стек вторую строку
		;push dx
		;call strcat
        ;mov dx, offset num1
		;pop dx ; извлекаем со стека возвращённое значение
        ;mov ah, 09h; 09h -- код для печати
        ;int 21h



        mov dx, offset dummy ; добавление перевод строки(?)
        mov ah, 09h
        int 21h

        ;mov dx, offset dummy; добавление перевод строки
        ;mov ah, 09h
        ;int 21h


        ;mov dx, offset num1
        ;add dx, 2
        ;mov ah, 09h
        ;int 21h
end_prog:
		mov ah, 4ch
		int 21h
code ends
end start
