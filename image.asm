section .text

extern calloc
extern free
extern malloc

global parseImage

struc Image
    size            resq 1; size of the image in bytes
    width           resq 1;
    height          resq 1;
    pixels          resq 1; pointer to Matrix instance
    depth           resq 1;
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
    mov r9, dword[r8]   ; store offset to raw pixel
                        ; data in r9
    add r8, 4
    cmp dword[r8], 40   ; check header size, 40 is standard
    jne .mismatch
    
    ;allocate memory for Image here,
    ;assuming the pointer to it is at RAX

    add r8, 4
    mov [rax + width], dword[r8]
    add r8, 4
    mov [rax + height], dword[r8]
    add r8, 6
    mov [rax + bpp], word[r8]
    add r8, 2
    cmp dword[r8], 0
    jne .mismatch
    lea r8, [rdi]
    add r8, r9          ; r8 points to the beginning of
                        ; pixel array, ready to start
                        ; filling the Matrix with data

.loopRows:

.loopCols:
    

.mismatch:
    ; standard procedures for mismatched input
    ret    
