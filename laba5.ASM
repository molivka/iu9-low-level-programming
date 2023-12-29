assume cs: code, ds: data

include macr.asm

data segment
string db 100, 100 dup('$')
symb db 100, 100 dup('$')
ans db 5 dup('$')
data ends

code segment

start:
    mov ax, data
    mov ds, ax

    str_in string

    str_in symb

    str_find string symb

end_prog:
		mov ah, 4ch
		int 21h
code ends
end start