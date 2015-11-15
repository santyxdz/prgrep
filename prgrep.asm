;--------------------------------------------------------------------;
;                          Parallel Grep
;--------------------------------------------------------------------;
; prgrep is a implementation of the linux-command grep written in
; the language Assembly for the Operative System Linux on the
; x86-64 architecture, using the Compile NASM (Netwide Assembler)
;--------------------------------------------------------------------; 
; Compile & Usage:
; nasm -f elf64 prgrep.asm
; ld prgrep.o --output=prgrep
; chmod +x prgrep
; ./prgrep
;--------------------------------------------------------------------;

;MACROS : Reemplaza donde es llamado por el codigo
%macro print 2
    mov rax,1 ;sys_write
    mov rdi,1 ;stdout
    mov rsi,%1 ;Argument
    mov rdx,%2
    syscall
%endmacro
%macro exit 0
    mov rax,60
    mov rdi,0
    syscall
%endmacro

section .text
;Procedimientos : Como un funcion
procedimiento_ex:
    print notFound,notFound
ret

;MAIN
    global _start ;Para que el enlazador sepa donde empezar
_start: ;like main()
    
    ;call procedimiento_ex
    ;print notFound,notFoundLen-5
    pop    rsi              ; number of arguments (argc)
    mov argc,rsi;
    pop    rsi              ; the command itself (or programname as you like)
    mov pname,rsi
    pop    rsi              ; the pointer to the string
    mov argv,rsi
    exit

section .data ;variables inicializadas
    ; <name_var> <size> <init_val>
    notFound db "No hay nada para buscar",0xA;10,13 | o12,o15 means \n\r
    notFoundLen equ $ - notFound ;sizeof(notFound) equ is a directive
    argc dd 0; dword
    pname db "./prgrep",0
    argv dd 0;
section .bss ;varibles no inicializadas
    ; <name_var> <size> <how_many>
    argc resq
    idarchivo resd 1 ; Archivo
    numlines resb 1; For lines