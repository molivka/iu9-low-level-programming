assume CS:code, DS:data

data segment
a db 1
b db 1
c db 6
d db 6
res dw 11
res2 dw 0
stroka db '00000', 0Dh, 0Ah, '$'
stroka2 db '00000', 0Dh, 0Ah, '$'
data ends

code segment
start:
mov ax, data
mov ds, ax

mov al, a
mov bl, b
mul bl; ax = al*bl
add res, ax; res = ax

mov al, c
mov bl, d
div bl; al = ax/bl
mov ah, 0
add res, ax
mov ax, res
mov res2, ax

mov bl, 10
m1:
    mov ax, res
    div bl
    add ah, '0'
    mov stroka[si + 4], ah
    xor ah, ah
    mov res, ax
    mov cx, res
    dec si
cmp ax, 0
jne m1

lea dx, stroka
mov ah, 9
int 21h


mov bx, 16
m2:
    mov ax, res2
    div bl
    cmp ah, 10
    jl m3
    add ah, 7
m3:
    add ah, '0'
    mov stroka2[di + 4], ah
    xor ah, ah
    mov res2, ax
    mov cx, res2
    dec di
cmp ax, 0
jne m2

lea dx, stroka2
mov ah, 9
int 21h


mov AX,4C00h
int 21h
code ends
end start