section .text

extern  getWidth
extern  getHeight
extern  getPixel
extern  setPixel

global  negative
global  black_and_white
global  blur
global  light


global  getRed
global  getBlue
global  getGreen
global  setRed
global  setBlue
global  setGreen

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
    cmp     rsi, 0
    jge     .ok1
        mov     rsi, 0
    .ok1:
    cmp     rsi, 255
    jle     .ok2
        mov     rsi, 255
    .ok2:
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
    cmp     rsi, 0
    jge     .ok1
        mov     rsi, 0
    .ok1:
    cmp     rsi, 255
    jle     .ok2
        mov     rsi, 255
    .ok2:

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
    cmp     rsi, 0
    jge     .ok1
        mov     rsi, 0
    .ok1:
    cmp     rsi, 255
    jle     .ok2
        mov     rsi, 255
    .ok2:

    xor     r8, r8
    mov     r8, 255
    shl     r8, 8
    not     r8
    and     rdi, r8
    shl     rsi, 8
    or      rdi, rsi
    ret


;void negative(Image in);
;rdi - in
negative:
    push    rdx
    push    rcx
    push    rbx
    push    rdi
    mov     rbx, rdi ;в rbx теперь ссылка на картинку
    call    getWidth
    mov     rcx, rax ;в rcx -- ширина
    call    getHeight
    mov     rdx, rax ;в rdx -- высота

    xor     r8, r8
    .loopX:
        xor     r9, r9
        .loopY:

            mov     r10, rdi ;в r10 теперь адрес картинки
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

            mov     r11, rax

            mov     rdi, r11
            call    getRed
            mov     r12, 255
            xchg    r12, rax
            sub     rax, r12

            mov     rdi, r11
            mov     rsi, rax
            call    setRed

            mov     r11, rdi

            mov     rdi, r11
            call    getBlue
            mov     r12, 255
            xchg    r12, rax
            sub     rax, r12

            mov     rdi, r11
            mov     rsi, rax
            call    setBlue

            mov     r11, rdi

            mov     rdi, r11
            call    getGreen
            mov     r12, 255
            xchg    r12, rax
            sub     rax, r12

            mov     rdi, r11
            mov     rsi, rax
            call    setGreen

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

    pop     rdi
    pop     rbx
    pop     rcx
    pop     rdx
    ret


;void black_and_white(Image in);
;rdi - in
black_and_white:
    push    rdx
    push    rcx
    push    rbx
    push    rdi
    mov     rbx, rdi ;в rbx теперь ссылка на картинку
    call    getWidth
    mov     rcx, rax ;в rcx -- ширина
    call    getHeight
    mov     rdx, rax ;в rdx -- высота

    xor     r8, r8
    .loopX:
        xor     r9, r9
        .loopY:

            mov     r10, rdi ;в r10 теперь адрес картинки
            push    r12
            push    r13
            push    r14
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

            mov     r11, rax

            mov     rdi, r11
            call    getRed
            mov     r12, rax

            mov     rdi, r11
            call    getBlue
            mov     r13, rax

            mov     rdi, r11
            call    getGreen
            mov     r14, rax

            ;r12 - red, r13 - blue, r14 - green
            push    rdx
            push    rax
            xor     rax, rax
            xor     rdx, rdx
            add     rax, r12
            add     rax, r13
            add     rax, r14
            mov     r8, 3
            div     r8
            mov     r12, rax
            mov     r13, rax
            mov     r14, rax
            pop     rax
            pop     rdx
            ;Store colors
            mov     rdi, r11
            mov     rsi, r12
            call    setRed

            mov     rsi, r13
            call    setBlue

            mov     rsi, r14
            call    setGreen

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
            pop     r14
            pop     r13
            pop     r12

            inc     r9
            cmp     r9, rcx
            jl      .loopY
        inc     r8
        cmp     r8, rdx
        jl      .loopX

    pop     rdi
    pop     rbx
    pop     rcx
    pop     rdx
    ret


;void blur(Image in);
;rdi - in
blur:
    push    rdx
    push    rcx
    push    rbx
    push    rdi
    mov     rbx, rdi ;в rbx теперь ссылка на картинку
    call    getWidth
    mov     rcx, rax ;в rcx -- ширина
    call    getHeight
    mov     rdx, rax ;в rdx -- высота

    xor     r8, r8
    .loopX:
        xor     r9, r9
        .loopY:

            mov     r10, rdi ;в r10 теперь адрес картинки
            push    r12
            push    r13
            push    r14
            push    rdi
            push    rsi
            push    rcx
            push    rdx
            push    r8
            push    r9
            push    r10


            xor     r12, r12
            xor     r13, r13
            xor     r14, r14
            push    rbx ;dx
            push    r15 ;dy
            xor     rbx, rbx
            mov     rbx, -1
            .loopXX:
                xor     r15, r15
                mov     r15, -1
                .loopYY:
                    push    r8
                    push    r9
                    push    r10
                    push    rcx
                    push    rdx

                    add     r8, rbx
                    cmp     r8, 0
                    jge     .ok1
                        mov     r8, 0
                    .ok1:
                    cmp     r8, rdx
                    jl      .ok2
                        mov     r8, rdx
                        dec     r8
                    .ok2:

                    add     r9, r15
                    cmp     r9, 0
                    jge     .ok3
                        mov     r9, 0
                    .ok3:
                    cmp     r9, rcx
                    jl      .ok4
                        mov     r9, rcx
                        dec     r9
                    .ok4:


                    mov     rdi, r10
                    mov     rsi, r8
                    mov     rdx, r9
                    call    getPixel

                    mov     r11, rax

                    mov     rdi, r11
                    call    getRed
                    add     r12, rax

                    mov     rdi, r11
                    call    getBlue
                    add     r13, rax

                    mov     rdi, r11
                    call    getGreen
                    add     r14, rax

                    pop     rdx
                    pop     rcx
                    pop     r10
                    pop     r9
                    pop     r8
                    inc     r15
                    cmp     r15, 2
                    jl      .loopYY
                inc     rbx
                cmp     rbx, 2
                jl      .loopXX

            pop     r15
            pop     rbx


            ;r12 - red, r13 - blue, r14 - green
            push    rdx
            push    rax
            xor     rax, rax
            xor     rdx, rdx
            mov     rax, r12
            mov     r8, 9
            div     r8
            mov     r12, rax
            pop     rax
            pop     rdx

            push    rdx
            push    rax
            xor     rax, rax
            xor     rdx, rdx
            mov     rax, r13
            mov     r8, 9
            div     r8
            mov     r13, rax
            pop     rax
            pop     rdx

            push    rdx
            push    rax
            xor     rax, rax
            xor     rdx, rdx
            mov     rax, r14
            mov     r8, 9
            div     r8
            mov     r14, rax
            pop     rax
            pop     rdx

            ;Store colors
            mov     rdi, r11
            mov     rsi, r12
            call    setRed

            mov     rsi, r13
            call    setBlue

            mov     rsi, r14
            call    setGreen

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
            pop     r14
            pop     r13
            pop     r12

            inc     r9
            cmp     r9, rcx
            jl      .loopY
        inc     r8
        cmp     r8, rdx
        jl      .loopX

    pop     rdi
    pop     rbx
    pop     rcx
    pop     rdx
    ret


;void light(Image in);
;rdi - in
light:
    push    rdx
    push    rcx
    push    rbx
    push    rdi
    push    r15
    call    getWidth
    mov     rcx, rax ;в rcx -- ширина
    call    getHeight
    mov     rdx, rax ;в rdx -- высота

    mov     rbx, rcx
    mov     r15, rdx

    push    rax
    push    rdx
    xor     rax, rax
    xor     rdx, rdx
    mov     rax, rbx
    mov     r8, 2
    div     r8
    mov     rbx, rax
    pop     rdx
    pop     rax

    push    rax
    push    rdx
    xor     rax, rax
    xor     rdx, rdx
    mov     rax, r15
    mov     r8, 2
    div     r8
    mov     r15, rax
    pop     rdx
    pop     rax


    xor     r8, r8
    .loopX:
        xor     r9, r9
        .loopY:

            mov     r10, rdi ;в r10 теперь адрес картинки
            push    r12
            push    r13
            push    r14
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

            mov     r11, rax

            mov     rdi, r11
            call    getRed
            mov     r12, rax

            mov     rdi, r11
            call    getBlue
            mov     r13, rax

            mov     rdi, r11
            call    getGreen
            mov     r14, rax

            ;r12 - red, r13 - blue, r14 - green

            push    r15
            push    rbx
            push    r10
            push    r11

            mov     r10, r15
            mov     r11, rbx

            sub     rbx, r9
            cmp     rbx, 0
            jge     .ok1
                neg     rbx
            .ok1:
            imul    rbx, 128
            push    rax
            push    rdx
            xor     rax, rax
            xor     rdx, rdx
            mov     rax, rbx
            div     r11
            mov     rbx, rax
            pop     rdx
            pop     rax

            sub     r15, r8
            cmp     r15, 0
            jge     .ok2
                neg     r15
            .ok2:
            imul    r15, 128
            push    rax
            push    rdx
            xor     rax, rax
            xor     rdx, rdx
            mov     rax, r15
            div     r10
            mov     r15, rax
            pop     rdx
            pop     rax


            add     r12, 50
            sub     r12, r15
            sub     r12, rbx

            add     r13, 50
            sub     r13, r15
            sub     r13, rbx

            add     r14, 50
            sub     r14, r15
            sub     r14, rbx

            pop     r11
            pop     r10
            pop     rbx
            pop     r15

            ;Store colors
            mov     rdi, r11
            mov     rsi, r12
            call    setRed

            mov     rsi, r13
            call    setBlue

            mov     rsi, r14
            call    setGreen

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
            pop     r14
            pop     r13
            pop     r12

            inc     r9
            cmp     r9, rcx
            jl      .loopY
        inc     r8
        cmp     r8, rdx
        jl      .loopX

    pop     r15
    pop     rdi
    pop     rbx
    pop     rcx
    pop     rdx
    ret
