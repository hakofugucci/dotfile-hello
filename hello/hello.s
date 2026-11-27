.globl _main
_main:
    adrp x0, m@PAGE
    add x0, x0, m@PAGEOFF
    b _puts
m:
    .asciz "Hello, World!"
