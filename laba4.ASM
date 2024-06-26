assume cs: code, ds: data

data segment
hex db 'Choose system 1->16 0->10$'
operation db 'Choose operation: + - *$'
errror db 'Invalid character$'
dummy db 0Dh, 0Ah, '$'; перевод строки
digit_num db 11 ;количество разрядов без учёта знака
sign1 db 0; знак первого
num1 db 12, 12 dup(0); первое число
mass1 db 22, 22 dup(0); массив1 чисел
sign2 db 0; знак второго
num2 db 12, 12 dup(0); второе число
mass2 db 22, 22 dup(0); массив2 чисел
result db 24, 24 dup('0'); ответ: знак + число + $
massres db 22, 22 dup(0); массив ответа
signres db 0; 1 если минус
error db 1; флаг ошибки
men db 1; флаг первое число меньше второго
ravn db 0; флаг что равны
flagnul db 0; флаг что 0 значащий
base db 10
pep_ans db 5, '0'
data ends

code segment

to_string proc
    mov si, offset result
    inc si
    mov di, offset massres
    cmp signres, 0
    je positive; i tried to be positive...
    mov byte ptr [si], '-'
    inc si
    positive:
    mov cx, 22
    add di, cx; идём с конца массива тк цифры в обратном порядке
    for_ch:
        cmp byte ptr [di], 0
        je flag
        jmp normnum
        flag:
        cmp flagnul, 0; если 0 не значащий
        je skip
        normnum:
        mov flagnul, 1
        xor ax, ax
        mov al, [di]
        mov [si], al
        cmp byte ptr [si], 10
        jb ok
        add byte ptr [si], 27h
        ok:
        add byte ptr [si], '0'
        inc si
        skip:
        dec di
    loop for_ch
    mov byte ptr [si], '$'
ret
to_string endp

to_int proc; в start пушим знак, массив, строку
    push bp
    mov bp, sp

    mov si, [bp+4]; строка
    mov di, [bp+6]; массив

    inc si; не учитываем максимальную длину строки
    xor cx, cx
    mov cl, [si];длина строки
    inc si;не учитываем фактическую длину строки
    mov bx, 0
    cmp byte ptr [si], '-'; проверка на отрицательность
    jne pos
    mov ax, 1
    mov bx, 1
    pos:
    dec si
    mov di, offset [bp+6]
    inc di; пропускаем ячейку с длиной массива
    add si, cx; чтобы идти с конца
    sub cx, bx;;a не sub?
	m:
	    xor dx, dx; чтобы не взять значения в dh
	    mov dl, [si]; последняя цифра строки
	    sub dl, '0'; приводим к числовому виду
	    cmp dl, 0
	    jb end_m; если меньше нуля, то не цифра
	    xor bx, bx
	    cmp dl, 10
	    jb ne_six; если меньше 10, то не переводим в 16 сс
	    mov bl, base
	    cmp bl, 16
	    jne ne_six
	    sub dl, 27h
	    cmp dl, 10
	    jb end_m; если < 10, то не цифра
	    cmp dl, 15
	    ja end_m; если больше 15, то не цифра
	    jmp sixt
	    ne_six:
	    cmp dl, 9
	    ja end_m; если больше 9, то не цифра
	    sixt:
	    mov [di], dl; записываем число в массив
	    inc di
	    dec si
	loop m
    mov error, 0
    end_m:
    pop bx; убираем со стека текущий адрес proc
	pop bx; сохраняем адрес возврата
	pop bp; достаём строку
	pop bp; достаём массив
	pop bp; достаём знак
	push ax; кладём знак
	push bx ; кладём адрес возврата
    ret
to_int endp

comp proc
    mov si, offset mass1; 1 число
    mov di, offset mass2; 2 число

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
    mov ravn, 1
    end_loop:
    mov men, 0
    endd:
    ret
comp endp

sum_unsign proc
    mov si, offset mass2;доступ ко второму массиву
    mov di, offset massres;доступ к массиву результата
    xor cx, cx
    mov cl, [si];кол-во цифр числа
    add si, 1; пропускаем ячейку с длинной
    add di, 1
    for:
        xor ax, ax
        mov al, [si]
        add al, [di]
        mov bl, base
        div bl
        mov [di], ah
        add [di+1], al
        inc si
        inc di
    loop for

    mov si, offset mass1
    mov di, offset massres;доступ к массиву результата
    xor cx, cx
    mov cl, [si];кол-во цифр числа
    add si, 1; пропускаем ячейку с длинной
    add di, 1
    for2:
        xor ax, ax
        mov al, [si]
        add al, [di]
        mov bl, base
        div bl
        mov [di], ah
        add [di+1], al
        inc si
        inc di
    loop for2
    ret
sum_unsign endp

sub_unsign proc;из di вычитаем si
    mov di, offset massres
    mov si, offset mass2; 2 - максимальное число
    mov bx, offset mass1
    cmp men, 1
    je op1; если первое число меньше второго
    mov si, offset mass1; 1 - максимальное число
    mov bx, offset mass2
    op1:
    xor cx, cx
    mov cl, [si];кол-во цифр числа
    inc si; пропускаем ячейку с длинной
    inc di
    for_sub:
        xor ax, ax
        mov al, [si]
        mov [di], al
        inc si
        inc di
    loop for_sub

    mov di, offset massres
    mov si, bx
    xor cx, cx
    mov cl, [si];кол-во цифр числа
    inc di
    inc si
    for_sub2:
        xor ax, ax
        mov al, [di]; текущая цифра
        add al, base; увеличиваем на разряд на всякий случай
        dec byte ptr [di+1]; убираем след разряд
        sub al, [si]
        mov bl, base
        div bl
        mov [di], ah
        add [di+1], al
        inc si
        inc di
    loop for_sub2
    ret
sub_unsign endp

mul_unsign proc
    mov si, offset mass1
    inc si
    mov cx, 0; число повторений цикла
    for1_start: ; метка, на которую проецируется цикл
        cmp cx, 11; кол-во итераций
        jnl for1_end; больше или равен -> выход
        mov bx, 0; счётчик второго цикла
        mov di, offset mass2
        inc di
        for2_start:
            cmp bx, 11
            jnl for2_end

            xor ax, ax
            mov al, [di]; умножение разрядов
            mul byte ptr [si]

            mov dx, si; сохраняем si тк нужно обратиться к массиву massres
            mov si, offset massres
            inc si
            add si, cx; ind в massres = cx+bx
            add si, bx
            add [si], ax;кладём ответ

            mov si, dx

            inc di
            inc bx
            jmp for2_start
        for2_end:
        inc si
        inc cx
        jmp for1_start
    for1_end:
    mov di, offset massres; редактируем результат, тк могли быть переполнения
    inc di
    mov cx, 21
    for_norm:
        xor ax, ax
        mov al, [di]
        mov bl, base
        div bl
        mov [di], ah
        add [di+1], al
        inc di
    loop for_norm
    ret
mul_unsign endp

start:
        mov ax, data
        mov ds, ax

        ;вопрос про 16 сс
        mov dx, offset hex
        mov ah, 09h
        int 21h

        mov dx, offset dummy ; добавление перевод строки
        mov ah, 09h
        int 21h

        mov dx, offset pep_ans;ввод ответа
        xor ax, ax
        mov ah, 0Ah
        int 21h

        mov dx, offset dummy; добавление перевод строки
        mov ah, 09h
        int 21h

        mov si, offset pep_ans
        add si, 2
        xor ax, ax
        mov al, [si]
        mov base, 10
        cmp ax, '0'
        je tenn
        mov base, 16
        tenn:
        mov dx, offset operation; вопрос про операцию
        mov ah, 09h
        int 21h

        mov dx, offset dummy; добавление перевод строки
        mov ah, 09h
        int 21h

        mov dx, offset pep_ans;ввод ответа
        xor ax, ax
        mov ah, 0Ah
        int 21h

        mov dx, offset dummy; добавление перевод строки
        mov ah, 09h
        int 21h

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
        pop ax
        mov sign1, al

        mov dx, offset dummy ; добавление перевод строки
        mov ah, 09h
        int 21h

        cmp error, 1
        je osh

        mov dx, offset num2; чтение 2 строки
        xor ax, ax
        mov ah, 0Ah
        int 21h

        mov error, 1

        mov dx, offset sign2
	    push dx
	    mov dx, offset mass2
	    push dx
	    mov dx, offset num2
	    push dx
        call to_int
        pop ax
        mov sign2, al

        mov dx, offset dummy; добавление перевод строки
        mov ah, 09h
        int 21h

        cmp error, 1
        je osh
        cmp error, 1
        jne not_err
        osh:
            mov dx, offset errror
            jmp dead

        not_err:

        call comp; заранее сравниваем

        mov di, offset pep_ans
        add di, 2

        cmp byte ptr[di], '+'
        je plus

        cmp byte ptr[di], '-'
        je minus

        cmp byte ptr[di], '*'
        je umnog

        minus:
        call sub_unsign
        jmp end_prog

        umnog:
        call mul_unsign
        mov al, sign1
        mov bl, sign2
        cmp al, bl
        je end_prog
        mov signres, 1
        jmp end_prog

        plus:
        xor ax, ax
        mov al, sign1
        add al, sign2
        cmp ax, 0; оба положительные
        je sum_pos
        cmp ax, 2; оба отрицательные
        je otr_sum
        cmp ravn, 1
        je nul
        cmp sign1, 0
        je f_pos; первое положительно
        cmp men, 1
        je s_res_pos; второе положительно и по модулю больше
        mov signres, 1
        s_res_pos:
        call sub_unsign
        jmp end_prog

        f_pos:;первое положительно
        cmp men, 0
        je f_res_pos
        mov signres, 1
        f_res_pos:
        call sub_unsign
        jmp end_prog

        ;сложение 2 отрицательных
        otr_sum:
        mov signres, 1
        call sum_unsign
        jmp end_prog

        sum_pos:;положительная сумма
        call sum_unsign
        jmp end_prog

        nul:
        mov si, offset result
        add si, 2
        mov byte ptr [si], '$'
        jmp print_ans


end_prog:
        call to_string
print_ans:
        mov dx, offset result
        inc dx
        mov ah, 09h
        int 21h
dead:
        mov ah, 4ch
        int 21h
code ends
end start