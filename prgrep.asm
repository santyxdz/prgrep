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
; gcc prgrep.o --output=prgrep (ld is supported but it can fail PD:uncomment 2nd line)
; chmod +x prgrep
; ./prgrep
;--------------------------------------------------------------------;
; Developed by:
; Santiago Montoya Angarita
; Juan Daniel Arboleda Sanchez
; Andres Mateo Otalvaro Bermudez
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
%define sizeof(x) x %+ _size ;use to STAT struc
;===========================END==MACROS=======================================;

;STAT struc, use to call sys_stat and save the information in
; stat (.bss variable) instance, and then extract st_size
; that's the size (in bytes) of a file.
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

;Procedimientos : Como una funcion
; parameters
;    for int and &points rdi,rsi,rdx,rcx,r8,r9
;    for float and doubles xmm[0-7]
;    for additional on the stack and removed by the caller
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
            push    rbp      ;backup                               
            mov     rbp, rsp                                
            mov     qword [rbp-8H], rdi ;fist number                    
            mov     qword [rbp-10H], rsi ;second number                   
            mov     rax, qword [rbp-8H] ; mov 1st to rax                    
            cmp     rax, qword [rbp-10H] ; compare with the 2nd one                   
            jle     max_001   ; si es <=                                
            mov     rax, qword [rbp-8H]  ;si no es el primero                  
            jmp     max_002            ;finaliza                       

    max_001:  mov     rax, qword [rbp-10H]  ; el 2nd es es max                  
    max_002:  pop     rbp  ;restore backup                                   
            ret            ;end sub-routine                                 
    ; max End of function

    ;=========MIN========
    ;Funcionamiento
    ;rax:int min_int(rdi:int,rsi:int)
    min:    ; Function begin
            push    rbp      ;backup                               
            mov     rbp, rsp                                
            mov     qword [rbp-8H], rdi ; 1st num                    
            mov     qword [rbp-10H], rsi   ; 2nd num                 
            mov     rax, qword [rbp-8H]    ; 1st to eax              
            cmp     rax, qword [rbp-10H]  ;compare 1st with 2nd                  
            jl      min_003  ;si es <                                 
            mov     rax, qword [rbp-8H]   ;si no el 1st                  
            jmp     min_004          ;fin                         

    min_003:  mov     rax, qword [rbp-10H]  ; el 2nd                  
    min_004:  pop     rbp     ;restore backup                                
            ret           ;end sub-rutina                                  
    ; min End of function

    ;=========STRLEN========
    ;Funcionamiento
    ;rax:int strlen(rdi:char*)
    strlen: ; Function begin
            push    rbp        ;backup                             
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi  ;1st argument                  
            mov     qword [rbp-8H], 0    ;counter i                  
            jmp     strlen_004        ;go while                           
    strlen_003:  add     qword [rbp-8H], 1   ;i=i+1                    
    strlen_004:  mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            test    al, al                                  
            jnz     strlen_003                                   
            mov     rax, qword [rbp-8H]                     
            pop     rbp     ;restore backup                                
            ret     ;end sub-routine                                        
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
    putsline:
        push rbp
        push r15
        mov rbp,rdi ; Parametro 1 Char*
        ;mov rdi,rbp
        movq rdi,xmm10
        call strlen
        add rax,10
        mov r15,rax ; Parametro 2 Length
        mov rax,1 ;sys_write
        mov rdi,1 ; stdout
        mov rsi,rbp ; Char *buf
        mov rdx,r15 ; length
        syscall
        pop r15
        pop rbp
        ret
    ;============PRINTLINE==========
    ; printline(rdi:int)
    printline:; Function begin
            push    rbp ;backup
            push    r12 ;backup
            movq    xmm12,rcx                                    
            mov     rbp, rsp 
            mov     r12,rdi ;Line number at 
            mov     rdi,found_in ;fount string
            call    puts       ;print                       
            movq    rdi, xmm8 ;name actual file
            call    puts ;print
            mov     rdi,line_at ; string ": "
            call    puts ;print
            movq    rsi,xmm12
            mov     rdi,buffer
            add     rdi,rsi
            call    putsline
            mov     rdi,nl
            call    puts
            pop     r12    ;restore backup                              
            pop     rbp    ;restore backup                                 
            ret                                             
    ; printline End of function

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
            call    strlen   ;length of 1st string                               
            mov     rbx, rax                                
            mov     rax, qword [rbp-20H]                    
            mov     rdi, rax                                
            call    strlen    ;length of 2nd string                               
            mov     rsi, rbx  ;1st                              
            mov     rdi, rax                                
            call    min      ;get the min length                              
            mov     qword [rbp-18H], rax  ;minumun=min                
            mov     qword [rbp-10H], 0    ;i=0;                  
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
            mov     rdx, qword [rbp-10H]  ;for(i=0l;i<minimun;i++){                  
            mov     rax, qword [rbp-20H]  ;       if(pat1[i]==pat2[i]){}else{           
            add     rax, rdx              ;            return (pat1[i]-pat2[i]);      
            movzx   eax, byte [rax]       ;    }              
            movsx   edx, al               ; }                 
            mov     rcx, qword [rbp-10H]                    
            mov     rax, qword [rbp-28H]                    
            add     rax, rcx                                
            movzx   eax, byte [rax]                         
            movsx   eax, al                                 
            sub     edx, eax                                
            mov     eax, edx                                
            cdqe        ;Double to Quad                                    
            jmp     compare_008                                   

    compare_006:  add     qword [rbp-10H], 1  ; i++                    
    compare_007:  mov     rax, qword [rbp-10H]                    
            cmp     rax, qword [rbp-18H]                    
            jl      compare_005                                   
            mov     eax, 0                                  
    compare_008:  add     rsp, 32                                 
            pop     rbx                                     
            pop     rbp                                     
            ret                                             
    ; compare End of function

    ;========TOLOWERCASE====;
    ; tolowercase(char*)
    tolowercase:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi                    
            mov     qword [rbp-8H], 0                       
            jmp     tolowercase_003                                   
    tolowercase_001:  mov     rdx, qword [rbp-8H]   
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            cmp     al, 64                                  
            jle     tolowercase_002                                   
            mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            cmp     al, 90                                  
            jg      tolowercase_002                    
            mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            mov     rcx, qword [rbp-8H]                     
            mov     rdx, qword [rbp-18H]                    
            add     rdx, rcx                                
            movzx   edx, byte [rdx]                         
            add     edx, 32                                 
            mov     byte [rax], dl                          
    tolowercase_002:  add     qword [rbp-8H], 1                       
    tolowercase_003:  mov     rdx, qword [rbp-8H]                     
            mov     rax, qword [rbp-18H]                    
            add     rax, rdx                                
            movzx   eax, byte [rax]                         
            test    al, al                                  
            jnz     tolowercase_001                                   
            nop                                             
            pop     rbp                                     
            ret            
    ; tolowercase End of function

    ;===========BadChar Table D1===========
    ; badCharHeuristic(rdi:char*,rdi:int,rdx:int[])
    badCharHeuristic:; Function begin
            push    rbp                                     
            mov     rbp, rsp                                
            mov     qword [rbp-18H], rdi ;char *str                   
            mov     qword [rbp-20H], rsi ;size                  
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

    ;===========Boyer-Moor Implementarion ========;
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
            mov     qword [rbp-68H], rdi  ;char *txt                  
            mov     qword [rbp-70H], rsi  ;char *pat                  
            mov     rax, rsp                                
            mov     rbx, rax                                
            mov     rax, qword [rbp-70H]                    
            mov     rdi, rax                                
            call    strlen                                  
            mov     qword [rbp-48H], rax  ; m (sizeof pat)                  
            mov     rax, qword [rbp-68H]                    
            mov     rdi, rax                                
            call    strlen                                  
            mov     qword [rbp-50H], rax   ;n (sizeof txt)                 
            mov     rax, qword [rel NO_OF_CHARS]            
            lea     rdx, [rax-1H]                           
            mov     qword [rbp-58H], rdx                    
            mov     rdx, rax                                
            mov     r14, rdx                                
            mov     r15d, 0                                 
            mov     rdx, rax                                
            mov     r12, rdx                                
            mov     r13d, 0                                 
            shl     rax, 3     ;shift logical left unsigned                            
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
            shr     rax, 3     ;shift logical right unsigned                         
            shl     rax, 3      ;shift logical left unsigned                             
            mov     qword [rbp-60H], rax                    
            mov     rdx, qword [rbp-60H]                    
            mov     rcx, qword [rbp-48H]                    
            mov     rax, qword [rbp-70H]                    
            mov     rsi, rcx ;size                               
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
            call    printline                             
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
        push r15 ; desplazamiento parametros
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
            mov r14,2 ; Actual argument
            mov r15,1 ; Where's the pattern
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
            mov rsi,[r12+8]
            mov rdi,ignorecaselong
            call compare
            cmp rax,0
            je ignorecase_section
            jmp without_options
        regexp_section:
            mov r15,2 ;pattern in 2nd place
            loop_regexp:
            movq xmm8,[r12+r14*8+8]; Char* file used
            openfile [r12+r14*8+8]
            movq xmm0,rax
            cmp rax,0
            jl end
            bytesof [r12+r14*8+8]
            movq xmm1,rax
            mov rsi,buffer
            movq rdi,xmm0
            movq rdx,xmm1
            mov rax,0 ;sys_read
            syscall
            mov rdi,buffer
            mov rsi,[r12+r15*8] ;Patron
            movq xmm10,[r12+r15*8]
            call search
            inc r14
            mov rdi,r14
            cmp rdi,r13
            je end
            jmp loop_regexp
        fileparam_section:
            mov r15,3; pattern in 3rd position
            movq xmm8,[r12+16]
            openfile [r12+16]
            movq xmm0,rax
            cmp rax,0
            jl loop_fileparam ; Review others
            bytesof [r12+16]
            movq xmm1,rax
            mov rsi,buffer
            movq rdi,xmm0
            movq rdx,xmm1
            mov rax,0 ;sys_read
            syscall
            mov rdi,buffer
            mov rsi,[r12+r15*8]
            movq xmm10,[r12+r15*8]
            call search
            mov r14,4 ;Others files starts at 32
            loop_fileparam:
            movq xmm8,[r12+r14*8]; base + (4*8) + 8*r14
            openfile [r12+r14*8]
            movq xmm0,rax
            cmp rax,0
            jl end
            bytesof [r12+r14*8]
            movq xmm1,rax
            mov rsi,buffer
            movq rdi,xmm0
            movq rdx,xmm1
            mov rax,0 ;sys_read
            syscall
            mov rdi,buffer
            mov rsi,[r12+r15*8]
            movq xmm10,[r12+r15*8]
            call search
            inc r14
            mov rdi,r14
            cmp rdi,r13
            je end
            jmp loop_fileparam
        ignorecase_section:
            mov r15,2 ;pattern in 2nd place
            loop_ignorecase:
            movq xmm8,[r12+r14*8+8]; Char* file used
            openfile [r12+r14*8+8]
            movq xmm0,rax
            cmp rax,0
            jl end
            bytesof [r12+r14*8+8]
            movq xmm1,rax
            mov rsi,buffer
            movq rdi,xmm0
            movq rdx,xmm1
            mov rax,0 ;sys_read
            syscall
            mov rdi,buffer
            call tolowercase
            mov rdi,[r12+r15*8]
            call tolowercase
            mov rdi,buffer
            mov rsi,[r12+r15*8]
            movq xmm10,[r12+r15*8]
            call search
            inc r14
            mov rdi,r14
            cmp rdi,r13
            je end
            jmp loop_ignorecase
        without_options:
            ;dec r13
            loop_without:
            movq xmm8,[r12+r14*8] ;Char* file used
            openfile [r12+r14*8]
            movq xmm0,rax
            bytesof [r12+r14*8]
            movq xmm1,rax
            mov rsi,buffer
            movq rdi,xmm0
            movq rdx,xmm1
            mov rax,0 ;sys_read
            syscall
            mov rdi,buffer
            mov rsi,[r12+r15*8]
            movq xmm10,[r12+r15*8]
            call search
            inc r14
            mov rdi,r14
            cmp rdi,r13 ;Test is like CMP but doesn't change
            je end ; if cont<argc -> end
            jmp loop_without
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
    found_in db "->found in ",0x0
    line_at db ": ",0x0
    NO_OF_CHARS dq 256 ;nums of chars in ascii standard
    not_found db "No hay nada para buscar",0xA,0x0;10,13 | o12,o15 means \n\r
    usage: db 0x9,"./prgrep [option] <PATTERN> [FILE...]",0xA
           db 0x9,"even when there are some optional arguments if",0xA
           db 0x9,"any of them it's not found perhaps it can fail. ",0xA,
           db 0x9,"options:",0xA
           db 0x9,"-e <PATTERN>",0xA
           db 0x9,"-f <FILE>",0xA
           db 0x9,"-i or --ignore-case",0xA
           db 0x0
    nl db "",0xA,0x0 ; \n
    regexp db "-e",0x0
    fileparam db "-f",0x0
    ignorecase db "-i",0x0
    ignorecaselong db "--ignore-case",0x0
    zero dd 0 ; Int->4Bytes->Double Word
section .bss ;varibles no inicializadas
    ; <name_var> <size> <how_many>
    idarchivo resd 1 ; Archivo
    numlines resb 1; For lines
    temp resd 1;
    stat resb 144 ;for struc
    buffer times 104857600 resb 1 ;100Mib