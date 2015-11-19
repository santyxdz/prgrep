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
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-8H], rdi                     
            mov     qword [rbp-10H], rsi                    
            mov     rax, qword [rbp-8H]                     
            cmp     rax, qword [rbp-10H]                    
            jle     ?_001                                   
            mov     rax, qword [rbp-8H]                     
            jmp     ?_002                                   

    ?_001:  mov     rax, qword [rbp-10H]                    
    ?_002:  pop     rbp                                     
            ret                                             
    ; max_int End of function

    strlen: ; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi                    
            mov     qword [rbp-8H], 0                       
            jmp     ?_004                                   

    ?_003:  add     qword [rbp-8H], 1                       
    ?_004:  mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            test    al, al                                  
            jnz     ?_003                                   
            mov     rax, qword [rbp-8H]                     
            pop     rbp                                     
            ret                                             
    ; strlen End of function
    puts:
        push rbp
        push r11
        mov rbp,rdi ; Parametro 1 Char*
        mov rdi,rbp
        call strlen
        mov r11,rax ; Parametro 2 Length
        mov rax,1 ;sys_write
        mov rdi,1 ; stdout
        mov rsi,rbp ; Char *buf
        mov rdx,r11 ; length
        syscall
        pop r11
        pop rbp
        ret
    println_int:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     edi, found                              
            call    puts                                    
            nop                                             
            pop     rbp                                     
            ret                                             
    ; println_int End of function

    badCharHeuristic:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi                    
            mov     qword [rbp-20H], rsi                    
            mov     qword [rbp-28H], rdx                    
            mov     qword [rbp-8H], 0                       
            jmp     ?_006                                   

    ?_005:  mov     rax, qword [rbp-8H]                     
            lea     rdx, [rax*8]                            
            mov     rax, qword [rbp-28H]                    
            add     rax, rdx                                
            mov     qword [rax], -1                         
            add     qword [rbp-8H], 1                       
    ?_006:  mov     rax, qword [rel NO_OF_CHARS]            
            cmp     qword [rbp-8H], rax                     
            jl      ?_005                                   
            mov     qword [rbp-8H], 0                       
            jmp     ?_008                                   

    ?_007:  mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            movsx   rax, al                                 
            lea     rdx, [rax*8]                            
            mov     rax, qword [rbp-28H]                    
            add     rdx, rax                                
            mov     rax, qword [rbp-8H]                     
            mov     qword [rdx], rax                        
            add     qword [rbp-8H], 1                       
    ?_008:  mov     rax, qword [rbp-8H]                     
            cmp     rax, qword [rbp-20H]                    
            jl      ?_007                                   
            nop                                             
            pop     rbp                                     
            ret                                             
    ; badCharHeuristic End of function

    search: ; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            push    r15                                     
            push    r14                                     
            push    r13                                     
            push    r12                                     
            push    rbx                                     
            sub     rsp, 72                                 
            mov     qword [rbp-68H], rdi                    
            mov     qword [rbp-70H], rsi                    
            mov     rax, rsp                                
            mov     rbx, rax                                
            mov     rax, qword [rbp-70H]                    
            mov     rdi, rax                                
            call    strlen                                  
            mov     qword [rbp-48H], rax                    
            mov     rax, qword [rbp-68H]                    
            mov     rdi, rax                                
            call    strlen                                  
            mov     qword [rbp-50H], rax                    
            mov     rax, qword [rel NO_OF_CHARS]            
            lea     rdx, [rax-1H]                           
            mov     qword [rbp-58H], rdx                    
            mov     rdx, rax                                
            mov     r14, rdx                                
            mov     r15d, 0                                 
            mov     rdx, rax                                
            mov     r12, rdx                                
            mov     r13d, 0                                 
            shl     rax, 3                                  
            lea     rdx, [rax+7H]                           
            mov     eax, 16                                 
            sub     rax, 1                                  
            add     rax, rdx                                
            mov     esi, 16                                 
            mov     edx, 0                                  
            div     rsi                                     
            imul    rax, rax, 16                            
            sub     rsp, rax                                
            mov     rax, rsp                                
            add     rax, 7                                  
            shr     rax, 3                                  
            shl     rax, 3                                  
            mov     qword [rbp-60H], rax                    
            mov     rdx, qword [rbp-60H]                    
            mov     rcx, qword [rbp-48H]                    
            mov     rax, qword [rbp-70H]                    
            mov     rsi, rcx                                
            mov     rdi, rax                                
            call    badCharHeuristic                        
            mov     qword [rbp-38H], 0                      
            jmp     ?_016                                   

    ?_009:  mov     rax, qword [rbp-48H]                    
            sub     rax, 1                                  
            mov     qword [rbp-40H], rax                    
            jmp     ?_011                                   

    ?_010:  sub     qword [rbp-40H], 1                      
    ?_011:  cmp     qword [rbp-40H], 0                      
            js      ?_012                                   
            mov     rdx, qword [rbp-40H]                    
            mov     rax, qword [rbp-70H]                    
            add     rax, rdx                                
            movzx   edx, byte [rax]                         
            mov     rcx, qword [rbp-38H]                    
            mov     rax, qword [rbp-40H]                    
            add     rax, rcx                                
            mov     rcx, rax                                
            mov     rax, qword [rbp-68H]                    
            add     rax, rcx                                
            movzx   eax, byte [rax]                         
            cmp     dl, al                                  
            jz      ?_010                                   
    ?_012:  cmp     qword [rbp-40H], 0                      
            jns     ?_015                                   
            mov     eax, 0                                  
            call    println_int                             
            mov     rdx, qword [rbp-38H]                    
            mov     rax, qword [rbp-48H]                    
            add     rax, rdx                                
            cmp     rax, qword [rbp-50H]                    
            jge     ?_013                                   
            mov     rdx, qword [rbp-38H]                    
            mov     rax, qword [rbp-48H]                    
            add     rax, rdx                                
            mov     rdx, rax                                
            mov     rax, qword [rbp-68H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            movsx   edx, al                                 
            mov     rax, qword [rbp-60H]                    
            movsxd  rdx, edx                                
            mov     rax, qword [rax+rdx*8]                  
            mov     rdx, qword [rbp-48H]                    
            sub     rdx, rax                                
            mov     rax, rdx                                
            jmp     ?_014                                   

    ?_013:  mov     eax, 1                                  
    ?_014:  add     qword [rbp-38H], rax                    
            jmp     ?_016                                   

    ?_015:  mov     rdx, qword [rbp-38H]                    
            mov     rax, qword [rbp-40H]                    
            add     rax, rdx                                
            mov     rdx, rax                                
            mov     rax, qword [rbp-68H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            movsx   edx, al                                 
            mov     rax, qword [rbp-60H]                    
            movsxd  rdx, edx                                
            mov     rax, qword [rax+rdx*8]                  
            mov     rdx, qword [rbp-40H]                    
            sub     rdx, rax                                
            mov     rax, rdx                                
            mov     rsi, rax                                
            mov     edi, 1                                  
            call    max_int                                 
            add     qword [rbp-38H], rax                    
    ?_016:  mov     rax, qword [rbp-50H]                    
            sub     rax, qword [rbp-48H]                    
            cmp     rax, qword [rbp-38H]                    
            jge     ?_009                                   
            mov     rsp, rbx                                
            nop                                             
            lea     rsp, [rbp-28H]                          
            pop     rbx                                     
            pop     r12                                     
            pop     r13                                     
            pop     r14                                     
            pop     r15                                     
            pop     rbp                                     
            ret                                             
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
            mov rdi,not_found
            call puts
            jmp end
        usage:

        args_found:
            mov r12,rsi ;ARGV +0=pname +8=argv[1] +16=argv[2]
            mov rsi,[r12+8] ;PATRON 2DO ARGUMENTO
            mov rdi,[r12+16] ;TEXTO 1ER ARGUMENTO
            call search
            mov rdi,[r12+8]
            call puts
            mov rdi,[r12+16]
            call puts
            jmp end
    ;return argc the direction
    ;return [argc] ;content of the direction
        end:
        pop r14
        pop r133/
        pop r12
    ret

section .data ;variables inicializadas
    ; <name_var> <size> <init_val>
    ;argc dd 0; dword
    ;pname db "./prgrep",0
    ;argv dd 0;
section .rodata
    found db "found",0xA,0x0
    NO_OF_CHARS dq 256 ;nums of chars in ascii standard
    not_found db "No hay nada para buscar",0xA,0x0;10,13 | o12,o15 means \n\r
    usage: db "./prgrep [option] <PATTERN> [File...]",0xA
           db "./prgrep [option] [-f File] [Files...]",0xA
           db "even when there are some optional arguments if any of them it's not found perhaps it can fail. ",0xA,
           db "Options:",0xA
           db "-e <PATTERN>",0xA
           db "-f <File>",0xA
           db "-i or --ignore-case",0xA
           db 0x0
    nl db "",0xA,0 ; \n
    nlen equ $ - nl
    zero dd 0 ; Int->4Bytes->Double Word
section .bss ;varibles no inicializadas
    ; <name_var> <size> <how_many>
    idarchivo resd 1 ; Archivo
    numlines resb 1; For lines
    temp resd 1;