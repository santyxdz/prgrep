global main
;global _start
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
    mov rdi,nl
    call puts
%endmacro
%macro bytesof 1 ;That's one of the prettiest things that I've ever done
    mov rax,4 ;sys_stat
    mov rdi,%1 ;filename char*
    mov rsi,stat ;struct stat *statbuf
    syscall
    mov rax,[stat + STAT.st_size] ; get st_size
%endmacro
%macro openfile 1
    mov rax,2
    mov rdi,%1
    mov rsi,0 ;READONLY/RDONLY
    mov rdx,0 ;If a file if created is RO
    syscall
%endmacro
%define sizeof(x) x %+ _size
;===========================END==MACROS=======================================;
struc STAT
    .st_dev         resq 1
    .st_ino         resq 1
    .st_nlink       resq 1
    .st_mode        resd 1
    .st_uid         resd 1
    .st_gid         resd 1
    .pad0           resb 4
    .st_rdev        resq 1
    .st_size        resq 1
    .st_blksize     resq 1
    .st_blocks      resq 1
    .st_atime       resq 1
    .st_atime_nsec  resq 1
    .st_mtime       resq 1
    .st_mtime_nsec  resq 1
    .st_ctime       resq 1
    .st_ctime_nsec  resq 1
endstruc

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



section .text
    ;============MAX==========
    ;Funcionamiento
    ;rax:int max(rdi:int,rsi:int)
    max:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-8H], rdi                     
            mov     qword [rbp-10H], rsi                    
            mov     rax, qword [rbp-8H]                     
            cmp     rax, qword [rbp-10H]                    
            jle     max_001                                   
            mov     rax, qword [rbp-8H]                     
            jmp     max_002                                   

    max_001:  mov     rax, qword [rbp-10H]                    
    max_002:  pop     rbp                                     
            ret                                             
    ; max End of function

    ;=========MIN========
    ;Funcionamiento
    ;rax:int min_int(rdi:int,rsi:int)
    min:    ; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-8H], rdi                     
            mov     qword [rbp-10H], rsi                    
            mov     rax, qword [rbp-8H]                     
            cmp     rax, qword [rbp-10H]                    
            jl      min_003                                   
            mov     rax, qword [rbp-8H]                     
            jmp     min_004                                   

    min_003:  mov     rax, qword [rbp-10H]                    
    min_004:  pop     rbp                                     
            ret                                             
    ; min End of function

    ;=========STRLEN========
    ;Funcionamiento
    ;rax:int strlen(rdi:char*)
    strlen: ; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi                    
            mov     qword [rbp-8H], 0                       
            jmp     strlen_004                                   

    strlen_003:  add     qword [rbp-8H], 1                       
    strlen_004:  mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            test    al, al                                  
            jnz     strlen_003                                   
            mov     rax, qword [rbp-8H]                     
            pop     rbp                                     
            ret                                             
    ; strlen End of function

    ;=========PUTS========
    ;Funcionamiento
    ;rax:int(of syscall) strlen(rdi:char*)
    puts:
        push rbp
        push r15
        mov rbp,rdi ; Parametro 1 Char*
        mov rdi,rbp
        call strlen
        mov r15,rax ; Parametro 2 Length
        mov rax,1 ;sys_write
        mov rdi,1 ; stdout
        mov rsi,rbp ; Char *buf
        mov rdx,r15 ; length
        syscall
        pop r15
        pop rbp
        ret
    ; println_int(rdi:int)
    println_int:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     rdi, found                              
            call    puts                                    
            nop                                             
            pop     rbp                                     
            ret                                             
    ; println_int End of function

    ;=========COMPARE========
    ;Funcionamiento
    ;rax:int compare(rdi:char*,rdi:char*)
    compare:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            push    rbx                                     
            sub     rsp, 32                                 
            mov     qword [rbp-20H], rdi                    
            mov     qword [rbp-28H], rsi                    
            mov     rax, qword [rbp-28H]                    
            mov     rdi, rax                                
            call    strlen                                  
            mov     rbx, rax                                
            mov     rax, qword [rbp-20H]                    
            mov     rdi, rax                                
            call    strlen                                  
            mov     rsi, rbx                                
            mov     rdi, rax                                
            call    min                                     
            mov     qword [rbp-18H], rax                    
            mov     qword [rbp-10H], 0                      
            mov     qword [rbp-10H], 0                      
            jmp     compare_007                                   

    compare_005:  mov     rdx, qword [rbp-10H]                    
            mov     rax, qword [rbp-20H]                    
            add     rax, rdx                                
            movzx   edx, byte [rax]                         
            mov     rcx, qword [rbp-10H]                    
            mov     rax, qword [rbp-28H]                    
            add     rax, rcx                                
            movzx   eax, byte [rax]                         
            cmp     dl, al                                  
            jz      compare_006                                   
            mov     rdx, qword [rbp-10H]                    
            mov     rax, qword [rbp-20H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            movsx   edx, al                                 
            mov     rcx, qword [rbp-10H]                    
            mov     rax, qword [rbp-28H]                    
            add     rax, rcx                                
            movzx   eax, byte [rax]                         
            movsx   eax, al                                 
            sub     edx, eax                                
            mov     eax, edx                                
            cdqe                                            
            jmp     compare_008                                   

    compare_006:  add     qword [rbp-10H], 1                      
    compare_007:  mov     rax, qword [rbp-10H]                    
            cmp     rax, qword [rbp-18H]                    
            jl      compare_005                                   
            mov     eax, 0                                  
    compare_008:  add     rsp, 32                                 
            pop     rbx                                     
            pop     rbp                                     
            ret                                             
    ; compare End of function

    ; badCharHeuristic(rdi:char*,rdi:int,rdx:int[])
    badCharHeuristic:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi                    
            mov     qword [rbp-20H], rsi                    
            mov     qword [rbp-28H], rdx                    
            mov     qword [rbp-8H], 0                       
            jmp     badCharHeuristic_006                                   

    badCharHeuristic_005:  mov     rax, qword [rbp-8H]                     
            lea     rdx, [rax*8]                            
            mov     rax, qword [rbp-28H]                    
            add     rax, rdx                                
            mov     qword [rax], -1                         
            add     qword [rbp-8H], 1                       
    badCharHeuristic_006:  mov     rax, qword [rel NO_OF_CHARS]            
            cmp     qword [rbp-8H], rax                     
            jl      badCharHeuristic_005                                   
            mov     qword [rbp-8H], 0                       
            jmp     badCharHeuristic_008                                   

    badCharHeuristic_007:  mov     rdx, qword [rbp-8H]                     
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
    badCharHeuristic_008:  mov     rax, qword [rbp-8H]                     
            cmp     rax, qword [rbp-20H]                    
            jl      badCharHeuristic_007                                   
            nop                                             
            pop     rbp                                     
            ret                                             
    ; badCharHeuristic End of function

    ; search(rdi:char*,rsi:char*) ;txt,pattern
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
            jmp     search_016                                   

    search_009:  mov     rax, qword [rbp-48H]                    
            sub     rax, 1                                  
            mov     qword [rbp-40H], rax                    
            jmp     search_011                                   

    search_010:  sub     qword [rbp-40H], 1                      
    search_011:  cmp     qword [rbp-40H], 0                      
            js      search_012                                   
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
            jz      search_010                                   
    search_012:  cmp     qword [rbp-40H], 0                      
            jns     search_015                                   
            mov     eax, 0                                  
            call    println_int                             
            mov     rdx, qword [rbp-38H]                    
            mov     rax, qword [rbp-48H]                    
            add     rax, rdx                                
            cmp     rax, qword [rbp-50H]                    
            jge     search_013                                   
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
            jmp     search_014                                   

    search_013:  mov     eax, 1                                  
    search_014:  add     qword [rbp-38H], rax                    
            jmp     search_016                                   

    search_015:  mov     rdx, qword [rbp-38H]                    
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
            call    max                                 
            add     qword [rbp-38H], rax                    
    search_016:  mov     rax, qword [rbp-50H]                    
            sub     rax, qword [rbp-48H]                    
            cmp     rax, qword [rbp-38H]                    
            jge     search_009                                   
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
        push r12 ;use as argv
        push r13 ;use as argc
        push r14 ; +argv
        push r15
        cmp rdi,1 ; Sin argumentos
        je not_args_found
        jg args_found
        jl end
        not_args_found:
            mov rdi,not_found
            call puts
            jmp end
        usage_message:
            mov rdi,usage
            call puts
            jmp end
        args_found:
            cmp rdi,2 ; Con un argumento
            je usage_message ; Mal uso
            mov r13,rdi ; argc in r13
            mov r12,rsi ; argv in r12 +0=pname +8=argv[1] +16=argv[2]
            mov r14,2
            ;=========ARGUMENTS DONE========;
            mov rsi,[r12+8] ;Fist Argument
            mov rdi,regexp ; if == -e
            call compare
            cmp rax,0
            je regexp_section
            mov rsi,[r12+8]
            mov rdi,fileparam; if == -f
            call compare
            cmp rax,0
            je fileparam_section
            mov rsi,[r12+8]
            mov rdi,ignorecase
            call compare
            cmp rax,0
            je ignorecase_section
            jmp without_options
        regexp_section:
            mov rdi,regexp
            call puts
            jmp end
        fileparam_section:
            mov rdi,fileparam
            call puts
            jmp end
        ignorecase_section:
            mov rdi,ignorecase
            call puts
            jmp end
            ; mov rsi,[r12+8] ;PATRON 2DO ARGUMENTO
            ; mov rdi,[r12+16] ;TEXTO 1ER ARGUMENTO
            ; call search
            ; mov rdi,[r12+8]
            ; call puts
            ; mov rdi,[r12+16]
            ; call puts
        without_options:
            openfile [r12+r14*8]
            movq mm0,rax
            bytesof [r12+r14*8]
            movq mm1,rax
            mov rsi,buffer
            movq rdi,mm0
            movq rdx,mm1
            mov rax,0
            syscall
            mov rdi,buffer
            mov rsi,[r12+8]
            call search
            


    ;return argc the direction
    ;return [argc] ;content of the direction
        end:
        pop r15
        pop r14
        pop r13
        pop r12
    ret

;
    _start:
        pop rax
        mov rdi,rax; ; argc 
        pop    rax   ; 
        mov rsi,rax ; argv
        call main
        mov r9,rax
        return r9 

section .data ;variables inicializadas
    ; <name_var> <size> <init_val>
    ;argc dd 0; dword
    ;pname db "./prgrep",0
    ;argv dd 0;
    stat_data istruc STAT iend
    filedescriptor dd -1
    hellofile db "./hello.txt"
section .rodata
    found db "found",0xA,0x0
    NO_OF_CHARS dq 256 ;nums of chars in ascii standard
    not_found db "No hay nada para buscar",0xA,0x0;10,13 | o12,o15 means \n\r
    usage: db 0x9,"./prgrep [option] <PATTERN> [File...]",0xA
           db 0x9,"./prgrep [option] [-f File] [Files...]",0xA
           db 0x9,"even when there are some optional arguments if any of them it's not found perhaps it can fail. ",0xA,
           db 0x9,"Options:",0xA
           db 0x9,"-e <PATTERN>",0xA
           db 0x9,"-f <File>",0xA
           db 0x9,"-i or --ignore-case",0xA
           db 0x0
    nl db "",0xA,0x0 ; \n
    regexp db "-e",0x0
    fileparam db "-f",0x0
    ignorecase db "-i",0x0
    zero dd 0 ; Int->4Bytes->Double Word
section .bss ;varibles no inicializadas
    ; <name_var> <size> <how_many>
    idarchivo resd 1 ; Archivo
    numlines resb 1; For lines
    temp resd 1;
    stat resb 144
    buffer times 104857600 resb 1