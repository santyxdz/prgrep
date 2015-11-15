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
%macro return 1
    mov rax,60
    mov rdi,%1
    syscall
%endmacro
%macro println 0
    print nl,nlen
%endmacro

section .text
;Procedimientos : Como una funcion
; parameters
;    for int and &points rdi,rsi,rdx,rcx,r8,r9
;    for float and doubles xmm[0-7]
;    for aditional on the stack and removed by the caller
;    when called function gets control ret_add is [rsp] and
;    1st memory paramaters is at [rsp+8]
;call-save reg rbp, rbx, r12, r13, r14, r15
; return
;    int in rax or rdx;rax
;    float xmm0 or xmm1:xmm0

;rax:int strlen(rdi=char*)
strlen:
    mov rdx, rdi
    xor rax,rax ; count = 0
    jmp overit
    looptop:
    inc rdx
    inc rax
    overit:
    cmp byte[rdx],0
    jnz looptop
ret
; end strlen

;======================MAIN============================
global _start ;Para que el enlazador sepa donde empezar
_start: ;like main()
        pop    rsi              ; number of arguments (argc)
        cmp rsi,1 ;No arguments
        je not_args_found
        jg args_found
        jl end
    args_found:
        dec rsi ; deleting name of program from arguments
        mov [argc],rsi; ;saving argc argument
        pop    rsi              ; the command itself (or programname as you like)
        mov [pname],rsi ;saving name of program
        pop    rsi              ; the pointer to the string
        mov [argv],rsi          ;saving pointer
        ;rax=strlen(argv)
        ;mov rdi,[argv]
        ;call strlen
        ; print(argv,strlen(argv))
        ;mov rcx,rax
        ;print [argv],rcx
        jmp end
    not_args_found:
        print not_found,not_found_len ;print string
        exit
    end:
        println
        exit

section .data ;variables inicializadas
    ; <name_var> <size> <init_val>
    not_found db "No hay nada para buscar",0xA;10,13 | o12,o15 means \n\r
    not_found_len equ $ - not_found ;sizeof(not_found) equ is a directive
    nl db "",0xA ; \n
    nlen equ $ - nl
    zero dd 0 ; Int->4Bytes->Double Word
    ;argc dd 0; dword
    ;pname db "./prgrep",0
    ;argv dd 0;
section .bss ;varibles no inicializadas
    ; <name_var> <size> <how_many>
    idarchivo resd 1 ; Archivo
    numlines resb 1; For lines
    argc resd 1;
    pname resb 10;
    argv resd 1;