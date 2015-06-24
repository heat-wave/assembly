section .text

extern calloc
extern free
extern malloc

global matrixNew
global matrixDelete
global matrixGetRows
global matrixGetCols
global matrixGet
global matrixSet

SIZE_OF_INT EQU 4

;multiples-of-4 alignment macro
%macro align_to_quad 1
;((x + 3) / 4) * 4
    add %1, 3
    shr %1, 2
    shl %1, 2
%endmacro

;macro to find the pointer to cell
;row = RSI, col = RDX, matrix_start = RDI
%macro get_cell_pointer 0
    imul rsi, [rdi + aligned_cols]
    add rsi, rdx    ; RSI =  cell number
    shl rsi, 2      ; RSI * 4 = cell start
    mov rax, [rdi + cells] ; RAX = pointer to first cell
    add rax, rsi
%endmacro

%macro fill_cell 1
    extractps [r13], xmm0, %1
    lea r13, [r13 + r10 * 4]
%endmacro

struc Matrix
    cells           resq 1 ; pointer to float array
    rows            resq 1 ; original number of rows
    cols         resq 1 ; original number of cols
    aligned_rows    resq 1 ; aligned number of rows
    aligned_cols    resq 1 ; aligned number of cols
endstruc

;Matrix matrixNew(unsigned int rows, unsigned int cols)
;creates new Matrix instance
;input:     RDI: number of rows
;           RSI: number of cols
;return:    RAX: pointer to Matrix instance on success, null on fail
matrixNew:
    push rdi ; save the state of registers
    push rsi

    mov rdi, Matrix_size ; allocate memory for the new Matrix
    call malloc

    mov rcx, rax ; RAX contains the result of calloc, store it in RCX
    pop rsi
    pop rdi

    mov [rax + rows], rdi
    mov [rax + cols], rsi

    align_to_quad rdi
    align_to_quad rsi
    mov [rax + aligned_rows], rdi
    mov [rax + aligned_cols], rsi

    imul rdi, rsi   ; calculate matrix size considering alignment
    mov rsi, SIZE_OF_INT

    push rcx
    call calloc
    pop rcx

    mov [rcx + cells], rax

    mov rax, rcx ; move pointer to Matrix instance to RAX
    
    ret

;void matrixDelete(Matrix matrix)
;deletes the Matrix and deallocates the memory it had been occupying
;input:     RDI: pointer to matrix
matrixDelete:
    push rdi
    mov rdi, [rdi + cells]
    call free ; delete cells

    pop rdi
    call free ; delete matrix
    ret

;unsigned int matrixGetRows(Matrix matrix)
;returns the number of rows in the Matrix
;input:     RDI: pointer to matrix
;return:    RAX: number of rows
matrixGetRows
    mov rax, [rdi + rows]
    ret

;unsigned int matrixGetCols(Matrix matrix)
;returns the number of cols in the Matrix
;input:     RDI: pointer to matrix
;return:    RAX: number of cols
matrixGetCols
    mov rax, [rdi + cols]
    ret

;float matrixGet(Matrix matrix, unsigned int row, unsigned int col)
;retrieves the value of a given cell
;input:     RDI: pointer to matrix
;           RSI: row number
;           RDX: col number
;return:    XMM0: value of the cell
matrixGet:
    get_cell_pointer
    movss xmm0, [rax]
    ret

;void matrixSet(Matrix matrix, unsigned int row, unsigned int col, float value)
;sets the value of a given cell
;input:     RDI: pointer to matrix
;           RSI: row number
;           RDX: col number
;           XMM0: value to be put into the cell
matrixSet:
    get_cell_pointer
    movss [rax], xmm0
    ret
