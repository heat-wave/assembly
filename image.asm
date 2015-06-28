section .text

extern calloc
extern free
extern malloc
extern matrixNew        ; TODO: can I really
extern matrixSet        ; declare Matrix functions here?
extern matrixGet

global parseImage
global getOffset
global getWidth
global getHeight
global getDepth
global getPixel
global setPixel
global upgradeDepth
global getSize
global getCopy

%macro save_dword 0
   xor r10, r10
   mov r10d, dword [r8]
%endmacro
   

struc Image
    sz:              resq 1;
    width:           resq 1;
    height:          resq 1;
    pixels:          resq 1; pointer to Matrix instance
    depth:           resq 1;
    offset:          resq 1;
    ;TODO: more fields if necessary

endstruc

;Image parseImage(file image)
;creates an instance of Image that contains
;all the necessary information about the image
;loaded from the BMP headers, and also the
;pixel array in 32-bit cells of Matrix
;input              RDI: pointer to the .bmp file
;return             RAX: pointer to the Image instance
;                        on success, null on fail
parseImage:
    push r8
    push rdi
    push rsi

    lea r8, [rdi]
    lea r14, [rdi] 
    cmp word[r8], 'BM'  ; 'BM' is non-OS/2 bitmap header
    jne .mismatch
    add r8, 2
    xor r13, r13
    mov r13d, dword[r8]
    add r8, 8
    xor r15, r15
    mov r15d, dword[r8]
    add r14, r15        ; store offset to raw pixel
                        ; data in r14
    add r8, 4
    cmp dword[r8], 40   ; check header size, 40 is standard
    jne .mismatch
    
    push r8
    push rdi            ; allocate memory for the
    push rsi            ; Image instance
    mov rdi, Image_size
    call malloc
    pop rsi             ; restore the registers'
    pop rdi             ; state
    pop r8

    mov [rax + sz], r13d
    mov [rax + offset], r15d
    add r8, 4           ; save the dimensions of the image
    save_dword
    mov [rax + width], r10d
    add r8, 4           ; in the corresponding fields
    save_dword
    mov [rax + height], r10d
    add r8, 6           ; of our Image instance
    save_dword
    mov [rax + depth], r10d
    add r8, 2
    cmp dword[r8], 0
    jne .mismatch

    push rax            ; create a Matrix that will serve
    mov rdi, [rax + height]
    mov rsi, [rax + width]
    ;push r8
    call matrixNew      ; as pixel storage in our Image
    ;pop r8
    mov r15, rax
    pop rax
    mov [rax + pixels], r15
    mov r8, r14
    ;add r8, r9          ; r8 points to the beginning of
                        ; pixel array, ready to start
                        ; filling the Matrix with data
    mov r13, [rax + depth]
    xor r10, r10
    cmp r13, 32
    jl .loops24
.loopOuter:             ; outer 'for' loop, iterating
    xor r11, r11        ; over rows

.loopInner:             ; inner 'for' loop, iterating
    inc r11             ; over columns
    mov rdi, r15 ;      [rax + pixels]
    mov rsi, r10
    mov rdx, r11
    movss xmm0, dword[r8] ; fill a cell in Matrix
    push r8
    call matrixSet
    pop r8
    add r8, 4           ; TODO: variable color depth?
    cmp r11, [rax + width]
    ;inc r11
    jl .loopInner

    inc r10
    cmp r10, [rax + height]
    jl .loopOuter 
    jmp .finally

.loops24:
    lea r11, [rax + sz]
    mov r14, [rax + width]
    imul r14, [rax + height]
    add [r11], r14
.loopOuter24:             ; outer 'for' loop, iterating
    xor r11, r11        ; over rows

.loopInner24:             ; inner 'for' loop, iterating
    inc r11             ; over columns
    mov rdi, r15 ;      [rax + pixels]
    mov rsi, r10
    mov rdx, r11
    mov r14d, dword[r8] ; fill a cell in Matrix
    shr r14, 8
    movd xmm0, r14
    movd r14, xmm0
    add r14, 255
    movd xmm0, r14
    push r8
    call matrixSet
    pop r8
    add r8, 3         ; TODO: variable color depth?
    cmp r11, [rax + width]
    ;inc r11
    jl .loopInner24

    inc r10
    cmp r10, [rax + height]
    jl .loopOuter24


.finally:               ; return, pointer to Image
    pop rsi
    pop rdi
    pop r8
    ret                 ; already saved in RAX

.mismatch:
    xor rax, rax
    mov ax, word[r8]
    mov rax, 0
    jmp .finally  

getOffset:
    mov rax, [rdi + offset]
    ret

getWidth:
    mov rax, [rdi + width]
    ret

getHeight:
    mov rax, [rdi + height]
    ret

getPixel:
    mov rdi, [rdi + pixels]
    call matrixGet
    movd rax, xmm0
    ret

setPixel:
    mov rdi, [rdi + pixels]
    movd xmm0, rcx
    call matrixSet
    ret

getDepth:
    mov rax, [rdi + depth]
    ret

getSize:
    mov rax, [rdi + sz]
    ret

upgradeDepth:
    mov rax, 32
    mov [rdi + depth], rax
    ret

getCopy:
    push rbx
    mov rbx, rdi
    push rdi
    mov rdi, Image_size
    call malloc
    pop rdi
    pop rbx
    mov r15, [rdi + sz]
    mov [rax + sz], r15
    mov r15, [rdi + depth]
    mov [rax + depth], r15
    mov r15, [rdi + offset]
    mov [rax + offset], r15
    mov r15, [rdi + width]
    mov [rax + width], r15
    mov r15, [rdi + height]
    mov [rax + height], r15
    push rax
    push rdi
    mov rdi, [rdi + width]
    mov rsi, r15
    call matrixNew
    mov r15, rax
    pop rdi
    pop rax
    mov [rax + pixels], r15
    push rax
    mov rsi, [rdi + pixels]
    mov rdi, [rax + pixels]
    push rax

.loopOuter:             ; outer 'for' loop, iterating
    xor r11, r11        ; over rows

.loopInner:             ; inner 'for' loop, iterating
    inc r11             ; over columns
    push rdi
    mov rdi, [rdi + pixels] ;      [rax + pixels]
    mov rsi, r10
    mov rdx, r11
    call matrixGet
    mov rdi, [rax + pixels]
    call matrixSet
    pop rdi
    cmp r11, [rax + width]
    inc r10
    cmp r10, [rax + height]
    jl .loopOuter 

    pop rax
    ret
    
