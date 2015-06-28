section .text

extern  getWidth
extern  getHeight
extern  getPixel
extern  setPixel

global negative
global getRed
global getBlue
global getGreen

;Красный хранится с 16 по 23 биты
;int getRed(int pixel);
;rdi - pixel
;результат в rax
getRed:
    mov     rax, rdi
    shr     rax, 16
    and     rax, 255
    ret

;Cиний хранится с 0 по 7 биты
;int getBlue(int pixel);
;rdi - pixel
;результат в rax
getBlue:
    mov     rax, rdi
    and     rax, 255
    ret

;Зеленый хранится с 8 по 15 биты
;int getGreen(int pixel);
;rdi - pixel
;результат в rax
getGreen:
    mov     rax, rdi
    shr     rax, 8
    and     rax, 255
    ret

;Красный хранится с 16 по 23 биты
;void setRed(int pixel, int value);
;rdi - pixel
;rsi - value
setRed:
    xor     r8, r8
    mov     r8, 255
    shl     r8, 16
    not     r8
    and     rdi, r8
    shl     rsi, 16
    or      rdi, rsi
    ret


;Cиний хранится с 0 по 7 биты
;void setBlue(int pixel, int value);
;rdi - pixel
;rsi - value
setBlue:
    xor     r8, r8
    mov     r8, 255
    not     r8
    and     rdi, r8
    or      rdi, rsi
    ret

;Зеленый хранится с 8 по 15 биты
;void setGreen(int pixel, int value);
;rdi - pixel
;rsi - value
setGreen:
    xor     r8, r8
    mov     r8, 255
    shl     r8, 8
    not     r8
    and     rdi, r8
    shl     rsi, 8
    or      rdi, rsi
    ret


;Image negative(Image in);
;rdi - in
;результат в rax
negative:
    push    rdx
    push    rcx
    push    rbx
    push rdi
    ;call    getCopy
    mov     rbx, rdi ;в rbx теперь ссылка на новую картинку
    call    getWidth
    mov     rcx, rax ;в rcx -- ширина
    call    getHeight
    mov     rdx, rax ;в rdx -- высота

    xor     r8, r8
    .loopX:
        xor     r9, r9
        .loopY:

            mov     r10, rdi
            push    r12
            push    rdi
            push    rsi
            push    rcx
            push    rdx
            push    r8
            push    r9
            push    r10

            mov     rdi, r10
            mov     rsi, r8
            mov     rdx, r9
            call    getPixel

            xor     r11, r11

            push    r11
            mov     rdi, rax
            call    getRed
            mov     r12, 255
            xchg    r12, rax
            sub     rax, r12
            pop     r11
            push    r11
            mov     rdi, r11
            mov     rsi, rax
            call    setRed
            pop     r11
            mov     r11, rdi

            push    r11
            mov     rdi, rax
            call    getBlue
            mov     r12, 255
            xchg    r12, rax
            sub     rax, r12
            pop     r11
            push    r11
            mov     rdi, r11
            mov     rsi, rax
            call    setBlue
            pop     r11
            mov     r11, rdi

            push    r11
            mov     rdi, rax
            call    getGreen
            mov     r12, 255
            xchg    r12, rax
            sub     rax, r12
            pop     r11
            push    r11
            mov     rdi, r11
            mov     rsi, rax
            call    setGreen
            pop     r11
            mov     r11, rdi

            pop     r10
            pop     r9
            pop     r8

            mov     rdi, r10
            mov     rsi, r8
            mov     rdx, r9
            mov     rcx, r11
            call    setPixel


            pop     rdx
            pop     rcx
            pop     rsi
            pop     rdi
            pop     r12

            inc     r9
            cmp     r9, rcx
            jl      .loopY
        inc     r8
        cmp     r8, rdx
        jl      .loopX

    pop     rax
    pop     rbx
    pop     rcx
    pop     rdx
    ret