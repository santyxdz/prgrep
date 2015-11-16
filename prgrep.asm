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
 extern puts

;================================MACROS=======================================;
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
;===========================END==MACROS=======================================;

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
;===========================STRLEN==================
;rax:int strlen(rdi=char*)


global main
section .text
    max_int:; Function begin
            push    rbp                                     ; 0000 _ 55
            mov     rbp, rsp                                ; 0001 _ 48: 89. E5
            mov     qword [rbp-8H], rdi                     ; 0004 _ 48: 89. 7D, F8
            mov     qword [rbp-10H], rsi                    ; 0008 _ 48: 89. 75, F0
            mov     rax, qword [rbp-8H]                     ; 000C _ 48: 8B. 45, F8
            cmp     rax, qword [rbp-10H]                    ; 0010 _ 48: 3B. 45, F0
            jle     ?_001                                   ; 0014 _ 7E, 06
            mov     rax, qword [rbp-8H]                     ; 0016 _ 48: 8B. 45, F8
            jmp     ?_002                                   ; 001A _ EB, 04

    ?_001:  mov     rax, qword [rbp-10H]                    ; 001C _ 48: 8B. 45, F0
    ?_002:  pop     rbp                                     ; 0020 _ 5D
            ret                                             ; 0021 _ C3
    ; max_int End of function

    strlen: ; Function begin
            push    rbp                                     ; 0022 _ 55
            mov     rbp, rsp                                ; 0023 _ 48: 89. E5
            mov     qword [rbp-18H], rdi                    ; 0026 _ 48: 89. 7D, E8
            mov     qword [rbp-8H], 0                       ; 002A _ 48: C7. 45, F8, 00000000
            jmp     ?_004                                   ; 0032 _ EB, 05

    ?_003:  add     qword [rbp-8H], 1                       ; 0034 _ 48: 83. 45, F8, 01
    ?_004:  mov     rdx, qword [rbp-8H]                     ; 0039 _ 48: 8B. 55, F8
            mov     rax, qword [rbp-18H]                    ; 003D _ 48: 8B. 45, E8
            add     rax, rdx                                ; 0041 _ 48: 01. D0
            movzx   eax, byte [rax]                         ; 0044 _ 0F B6. 00
            test    al, al                                  ; 0047 _ 84. C0
            jnz     ?_003                                   ; 0049 _ 75, E9
            mov     rax, qword [rbp-8H]                     ; 004B _ 48: 8B. 45, F8
            pop     rbp                                     ; 004F _ 5D
            ret                                             ; 0050 _ C3
    ; strlen End of function

    println_int:; Function begin
            push    rbp                                     ; 0051 _ 55
            mov     rbp, rsp                                ; 0052 _ 48: 89. E5
            mov     edi, found                              ; 0055 _ BF, 00000000(d)
            call    puts                                    ; 005A _ E8, 00000000(rel)
            nop                                             ; 005F _ 90
            pop     rbp                                     ; 0060 _ 5D
            ret                                             ; 0061 _ C3
    ; println_int End of function

    badCharHeuristic:; Function begin
            push    rbp                                     ; 0062 _ 55
            mov     rbp, rsp                                ; 0063 _ 48: 89. E5
            mov     qword [rbp-18H], rdi                    ; 0066 _ 48: 89. 7D, E8
            mov     qword [rbp-20H], rsi                    ; 006A _ 48: 89. 75, E0
            mov     qword [rbp-28H], rdx                    ; 006E _ 48: 89. 55, D8
            mov     qword [rbp-8H], 0                       ; 0072 _ 48: C7. 45, F8, 00000000
            jmp     ?_006                                   ; 007A _ EB, 1F

    ?_005:  mov     rax, qword [rbp-8H]                     ; 007C _ 48: 8B. 45, F8
            lea     rdx, [rax*8]                            ; 0080 _ 48: 8D. 14 C5, 00000000
            mov     rax, qword [rbp-28H]                    ; 0088 _ 48: 8B. 45, D8
            add     rax, rdx                                ; 008C _ 48: 01. D0
            mov     qword [rax], -1                         ; 008F _ 48: C7. 00, FFFFFFFF
            add     qword [rbp-8H], 1                       ; 0096 _ 48: 83. 45, F8, 01
    ?_006:  mov     rax, qword [rel NO_OF_CHARS]            ; 009B _ 48: 8B. 05, 00000000(rel)
            cmp     qword [rbp-8H], rax                     ; 00A2 _ 48: 39. 45, F8
            jl      ?_005                                   ; 00A6 _ 7C, D4
            mov     qword [rbp-8H], 0                       ; 00A8 _ 48: C7. 45, F8, 00000000
            jmp     ?_008                                   ; 00B0 _ EB, 2D

    ?_007:  mov     rdx, qword [rbp-8H]                     ; 00B2 _ 48: 8B. 55, F8
            mov     rax, qword [rbp-18H]                    ; 00B6 _ 48: 8B. 45, E8
            add     rax, rdx                                ; 00BA _ 48: 01. D0
            movzx   eax, byte [rax]                         ; 00BD _ 0F B6. 00
            movsx   rax, al                                 ; 00C0 _ 48: 0F BE. C0
            lea     rdx, [rax*8]                            ; 00C4 _ 48: 8D. 14 C5, 00000000
            mov     rax, qword [rbp-28H]                    ; 00CC _ 48: 8B. 45, D8
            add     rdx, rax                                ; 00D0 _ 48: 01. C2
            mov     rax, qword [rbp-8H]                     ; 00D3 _ 48: 8B. 45, F8
            mov     qword [rdx], rax                        ; 00D7 _ 48: 89. 02
            add     qword [rbp-8H], 1                       ; 00DA _ 48: 83. 45, F8, 01
    ?_008:  mov     rax, qword [rbp-8H]                     ; 00DF _ 48: 8B. 45, F8
            cmp     rax, qword [rbp-20H]                    ; 00E3 _ 48: 3B. 45, E0
            jl      ?_007                                   ; 00E7 _ 7C, C9
            nop                                             ; 00E9 _ 90
            pop     rbp                                     ; 00EA _ 5D
            ret                                             ; 00EB _ C3
    ; badCharHeuristic End of function

    search: ; Function begin
            push    rbp                                     ; 00EC _ 55
            mov     rbp, rsp                                ; 00ED _ 48: 89. E5
            push    r15                                     ; 00F0 _ 41: 57
            push    r14                                     ; 00F2 _ 41: 56
            push    r13                                     ; 00F4 _ 41: 55
            push    r12                                     ; 00F6 _ 41: 54
            push    rbx                                     ; 00F8 _ 53
            sub     rsp, 72                                 ; 00F9 _ 48: 83. EC, 48
            mov     qword [rbp-68H], rdi                    ; 00FD _ 48: 89. 7D, 98
            mov     qword [rbp-70H], rsi                    ; 0101 _ 48: 89. 75, 90
            mov     rax, rsp                                ; 0105 _ 48: 89. E0
            mov     rbx, rax                                ; 0108 _ 48: 89. C3
            mov     rax, qword [rbp-70H]                    ; 010B _ 48: 8B. 45, 90
            mov     rdi, rax                                ; 010F _ 48: 89. C7
            call    strlen                                  ; 0112 _ E8, 00000000(rel)
            mov     qword [rbp-48H], rax                    ; 0117 _ 48: 89. 45, B8
            mov     rax, qword [rbp-68H]                    ; 011B _ 48: 8B. 45, 98
            mov     rdi, rax                                ; 011F _ 48: 89. C7
            call    strlen                                  ; 0122 _ E8, 00000000(rel)
            mov     qword [rbp-50H], rax                    ; 0127 _ 48: 89. 45, B0
            mov     rax, qword [rel NO_OF_CHARS]            ; 012B _ 48: 8B. 05, 00000000(rel)
            lea     rdx, [rax-1H]                           ; 0132 _ 48: 8D. 50, FF
            mov     qword [rbp-58H], rdx                    ; 0136 _ 48: 89. 55, A8
            mov     rdx, rax                                ; 013A _ 48: 89. C2
            mov     r14, rdx                                ; 013D _ 49: 89. D6
            mov     r15d, 0                                 ; 0140 _ 41: BF, 00000000
            mov     rdx, rax                                ; 0146 _ 48: 89. C2
            mov     r12, rdx                                ; 0149 _ 49: 89. D4
            mov     r13d, 0                                 ; 014C _ 41: BD, 00000000
            shl     rax, 3                                  ; 0152 _ 48: C1. E0, 03
            lea     rdx, [rax+7H]                           ; 0156 _ 48: 8D. 50, 07
            mov     eax, 16                                 ; 015A _ B8, 00000010
            sub     rax, 1                                  ; 015F _ 48: 83. E8, 01
            add     rax, rdx                                ; 0163 _ 48: 01. D0
            mov     esi, 16                                 ; 0166 _ BE, 00000010
            mov     edx, 0                                  ; 016B _ BA, 00000000
            div     rsi                                     ; 0170 _ 48: F7. F6
            imul    rax, rax, 16                            ; 0173 _ 48: 6B. C0, 10
            sub     rsp, rax                                ; 0177 _ 48: 29. C4
            mov     rax, rsp                                ; 017A _ 48: 89. E0
            add     rax, 7                                  ; 017D _ 48: 83. C0, 07
            shr     rax, 3                                  ; 0181 _ 48: C1. E8, 03
            shl     rax, 3                                  ; 0185 _ 48: C1. E0, 03
            mov     qword [rbp-60H], rax                    ; 0189 _ 48: 89. 45, A0
            mov     rdx, qword [rbp-60H]                    ; 018D _ 48: 8B. 55, A0
            mov     rcx, qword [rbp-48H]                    ; 0191 _ 48: 8B. 4D, B8
            mov     rax, qword [rbp-70H]                    ; 0195 _ 48: 8B. 45, 90
            mov     rsi, rcx                                ; 0199 _ 48: 89. CE
            mov     rdi, rax                                ; 019C _ 48: 89. C7
            call    badCharHeuristic                        ; 019F _ E8, 00000000(rel)
            mov     qword [rbp-38H], 0                      ; 01A4 _ 48: C7. 45, C8, 00000000
            jmp     ?_016                                   ; 01AC _ E9, 000000E4

    ?_009:  mov     rax, qword [rbp-48H]                    ; 01B1 _ 48: 8B. 45, B8
            sub     rax, 1                                  ; 01B5 _ 48: 83. E8, 01
            mov     qword [rbp-40H], rax                    ; 01B9 _ 48: 89. 45, C0
            jmp     ?_011                                   ; 01BD _ EB, 05

    ?_010:  sub     qword [rbp-40H], 1                      ; 01BF _ 48: 83. 6D, C0, 01
    ?_011:  cmp     qword [rbp-40H], 0                      ; 01C4 _ 48: 83. 7D, C0, 00
            js      ?_012                                   ; 01C9 _ 78, 2A
            mov     rdx, qword [rbp-40H]                    ; 01CB _ 48: 8B. 55, C0
            mov     rax, qword [rbp-70H]                    ; 01CF _ 48: 8B. 45, 90
            add     rax, rdx                                ; 01D3 _ 48: 01. D0
            movzx   edx, byte [rax]                         ; 01D6 _ 0F B6. 10
            mov     rcx, qword [rbp-38H]                    ; 01D9 _ 48: 8B. 4D, C8
            mov     rax, qword [rbp-40H]                    ; 01DD _ 48: 8B. 45, C0
            add     rax, rcx                                ; 01E1 _ 48: 01. C8
            mov     rcx, rax                                ; 01E4 _ 48: 89. C1
            mov     rax, qword [rbp-68H]                    ; 01E7 _ 48: 8B. 45, 98
            add     rax, rcx                                ; 01EB _ 48: 01. C8
            movzx   eax, byte [rax]                         ; 01EE _ 0F B6. 00
            cmp     dl, al                                  ; 01F1 _ 38. C2
            jz      ?_010                                   ; 01F3 _ 74, CA
    ?_012:  cmp     qword [rbp-40H], 0                      ; 01F5 _ 48: 83. 7D, C0, 00
            jns     ?_015                                   ; 01FA _ 79, 58
            mov     eax, 0                                  ; 01FC _ B8, 00000000
            call    println_int                             ; 0201 _ E8, 00000000(rel)
            mov     rdx, qword [rbp-38H]                    ; 0206 _ 48: 8B. 55, C8
            mov     rax, qword [rbp-48H]                    ; 020A _ 48: 8B. 45, B8
            add     rax, rdx                                ; 020E _ 48: 01. D0
            cmp     rax, qword [rbp-50H]                    ; 0211 _ 48: 3B. 45, B0
            jge     ?_013                                   ; 0215 _ 7D, 32
            mov     rdx, qword [rbp-38H]                    ; 0217 _ 48: 8B. 55, C8
            mov     rax, qword [rbp-48H]                    ; 021B _ 48: 8B. 45, B8
            add     rax, rdx                                ; 021F _ 48: 01. D0
            mov     rdx, rax                                ; 0222 _ 48: 89. C2
            mov     rax, qword [rbp-68H]                    ; 0225 _ 48: 8B. 45, 98
            add     rax, rdx                                ; 0229 _ 48: 01. D0
            movzx   eax, byte [rax]                         ; 022C _ 0F B6. 00
            movsx   edx, al                                 ; 022F _ 0F BE. D0
            mov     rax, qword [rbp-60H]                    ; 0232 _ 48: 8B. 45, A0
            movsxd  rdx, edx                                ; 0236 _ 48: 63. D2
            mov     rax, qword [rax+rdx*8]                  ; 0239 _ 48: 8B. 04 D0
            mov     rdx, qword [rbp-48H]                    ; 023D _ 48: 8B. 55, B8
            sub     rdx, rax                                ; 0241 _ 48: 29. C2
            mov     rax, rdx                                ; 0244 _ 48: 89. D0
            jmp     ?_014                                   ; 0247 _ EB, 05

    ?_013:  mov     eax, 1                                  ; 0249 _ B8, 00000001
    ?_014:  add     qword [rbp-38H], rax                    ; 024E _ 48: 01. 45, C8
            jmp     ?_016                                   ; 0252 _ EB, 41

    ?_015:  mov     rdx, qword [rbp-38H]                    ; 0254 _ 48: 8B. 55, C8
            mov     rax, qword [rbp-40H]                    ; 0258 _ 48: 8B. 45, C0
            add     rax, rdx                                ; 025C _ 48: 01. D0
            mov     rdx, rax                                ; 025F _ 48: 89. C2
            mov     rax, qword [rbp-68H]                    ; 0262 _ 48: 8B. 45, 98
            add     rax, rdx                                ; 0266 _ 48: 01. D0
            movzx   eax, byte [rax]                         ; 0269 _ 0F B6. 00
            movsx   edx, al                                 ; 026C _ 0F BE. D0
            mov     rax, qword [rbp-60H]                    ; 026F _ 48: 8B. 45, A0
            movsxd  rdx, edx                                ; 0273 _ 48: 63. D2
            mov     rax, qword [rax+rdx*8]                  ; 0276 _ 48: 8B. 04 D0
            mov     rdx, qword [rbp-40H]                    ; 027A _ 48: 8B. 55, C0
            sub     rdx, rax                                ; 027E _ 48: 29. C2
            mov     rax, rdx                                ; 0281 _ 48: 89. D0
            mov     rsi, rax                                ; 0284 _ 48: 89. C6
            mov     edi, 1                                  ; 0287 _ BF, 00000001
            call    max_int                                 ; 028C _ E8, 00000000(rel)
            add     qword [rbp-38H], rax                    ; 0291 _ 48: 01. 45, C8
    ?_016:  mov     rax, qword [rbp-50H]                    ; 0295 _ 48: 8B. 45, B0
            sub     rax, qword [rbp-48H]                    ; 0299 _ 48: 2B. 45, B8
            cmp     rax, qword [rbp-38H]                    ; 029D _ 48: 3B. 45, C8
            jge     ?_009                                   ; 02A1 _ 0F 8D, FFFFFF0A
            mov     rsp, rbx                                ; 02A7 _ 48: 89. DC
            nop                                             ; 02AA _ 90
            lea     rsp, [rbp-28H]                          ; 02AB _ 48: 8D. 65, D8
            pop     rbx                                     ; 02AF _ 5B
            pop     r12                                     ; 02B0 _ 41: 5C
            pop     r13                                     ; 02B2 _ 41: 5D
            pop     r14                                     ; 02B4 _ 41: 5E
            pop     r15                                     ; 02B6 _ 41: 5F
            pop     rbp                                     ; 02B8 _ 5D
            ret                                             ; 02B9 _ C3
    ; search End of function
;======================MAIN============================
    main:
        push r12
        push r13
        push r14
        cmp rdi,1
        je not_args_found
        jg args_found
        jl end
        not_args_found:
            print not_found,not_found_len
            jmp end
        args_found:
            mov r12,rsi ;ARGV +0=pname +8=argv[1] +16=argv[2]
            mov rsi,[r12+8]
            mov rdi,[r12+16]
            call search
            jmp end
    ;return argc the direction
    ;return [argc] ;content of the direction
        end:
        pop r14
        pop r13
        pop r12
    ret

section .data ;variables inicializadas
    ; <name_var> <size> <init_val>
    ;argc dd 0; dword
    ;pname db "./prgrep",0
    ;argv dd 0;
section .rodata
    found db "found",0xA,0x0
    found_len equ $-found
    NO_OF_CHARS dq 256 ;nums of chars in ascii standard
    not_found db "No hay nada para buscar",0xA,0x0;10,13 | o12,o15 means \n\r
    not_found_len equ $ - not_found ;sizeof(not_found) equ is a directive
    nl db "",0xA,0 ; \n
    nlen equ $ - nl
    zero dd 0 ; Int->4Bytes->Double Word
section .bss ;varibles no inicializadas
    ; <name_var> <size> <how_many>
    idarchivo resd 1 ; Archivo
    numlines resb 1; For lines
    argc resd 1;
    pname resb 10;
    argv resd 1;
    temp resd 1;