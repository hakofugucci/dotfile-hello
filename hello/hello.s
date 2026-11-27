.section __TEXT,__text
.globl _main
.p2align 2
_main:
    adrp x0, m@PAGE
    add x0, x0, m@PAGEOFF
    b _puts
.section __TEXT,__cstring
m:
    .asciz "hello, world"
