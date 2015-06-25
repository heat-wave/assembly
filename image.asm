section .text

extern calloc
extern free
extern malloc
extern matrixNew        ; TODO: can I really
extern matrixSet        ; declare Matrix functions here?

global parseImage

%macro save_dword 0
   xor r10, r10
   mov r10d, dword [r8]
%endmacro
   

struc Image
    sz:              resq 1; size of the image in bytes
    width:           resd 1;
    height:          resd 1;
    pixels:          resq 1; pointer to Matrix instance
    depth:           resw 1;
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
    lea r8, [rdi]
    cmp word[r8], 'BM'  ; 'BM' is non-OS/2 bitmap header
    jne .mismatch
    add r8, 10
    xor r9, r9
    mov r9d, dword[r8]  ; store offset to raw pixel
                        ; data in r9
    add r8, 4
    cmp dword[r8], 40   ; check header size, 40 is standard
    jne .mismatch
    
    push rdi            ; allocate memory for the
    push rsi            ; Image instance
    mov rdi, Image_size
    call malloc
    pop rsi             ; restore the registers'
    pop rdi             ; state

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
    call matrixNew      ; as pixel storage in our Image
    mov r15, rax
    pop rax
    mov [rax + pixels], r15

    lea r8, [rdi]
    add r8, r9          ; r8 points to the beginning of
                        ; pixel array, ready to start
                        ; filling the Matrix with data
    xor r10, r10
.loopOuter:             ; outer 'for' loop, iterating
    xor r11, r11        ; over rows

.loopInner:             ; inner 'for' loop, iterating
    inc r11             ; over columns
    mov rdi, [rax + pixels]
    mov rsi, r10
    mov rdx, r11
    movss xmm0, dword[r8] ; fill a cell in Matrix
    call matrixSet
    add r8, 4           ; TODO: variable color depth?
    cmp r11, [rax + width]
    jl .loopInner

    inc r10
    cmp r10, [rax + height]
    jl .loopOuter
 
.finally:               ; return, pointer to Image
    ret                 ; already saved in RAX

.mismatch:
    mov rax, 0
    ret    
