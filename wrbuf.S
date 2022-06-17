#define MYCODE
#ifdef MYCODE
// version 1.0 05/27/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified
    
    // import constants
    #include "encrypter.h"

    .section .rodata
.Lmsg: .string "wrbuf: Write failed on output\n"
.Lmsg2: .string "wrbuf: Buffer size error\n"

    .text

    ///////////////////////////////////////////////////
    // int wrbuf(char *IOBUF, int cnt, FILE *FPOUT); //
    // return cnt on success EXIT_FAIL otherwise     //
    ///////////////////////////////////////////////////
    .type   wrbuf, %function
    .global wrbuf
    .equ    FP_OFF, 12

    ////////////////////////////////////////
    // preserved register use             //
    // r4 cnt                             //
    //////////////////////////////////////// 

wrbuf:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    cmp     r1, 0
    ble     .Lerr1

    mov     r4, r1
    mov     r3, r2
    mov     r2, r1
    mov     r1, 1

    bl      fwrite
    cmp     r0, r4
    bne     .Lerr2

    mov     r0, r4
    b       .Ldone

.Lerr1:
    ldr     r0, =.Lmsg2
    bl      errmsg
    mov     r0, -1
    b       .Ldone

.Lerr2:
    ldr     r0, =.Lmsg
    bl      errmsg
    mov     r0, -1
    b       .Ldone

.Ldone:
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size   wrbuf, (. - wrbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif
