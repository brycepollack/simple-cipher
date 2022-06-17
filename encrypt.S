#define MYCODE
#ifdef MYCODE
// version 1.0 05/22/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "encrypter.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int encrypt(char *IOBUF, char *BOOKBUF, int cnt)
    // encrypts  IOBUF with BOOKBUF; updating IOBUF
    //////////////////////////////////////////////////
    .global encrypt
    .type   encrypt, %function
    .equ    FP_OFF, 12

    ////////////////////////////////////////
    // preserved register use             //
    // r4 IOBUF byte/mask                 //
    // r5 i                               //
    ////////////////////////////////////////

encrypt:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    mov     r4, 0
    mov     r5, 0 //r5: i

.Lloop:
    //if i >= cnt, break
    cmp     r5, r2
    bge     .Ldone

    //r4 = lower nibble, r3 = upper nibble
    ldrb    r4, [r0, r5]
    mov     r3, 0
    add     r3, r4, 0
    //swap nibbles
    lsl     r4, r4, 4
    lsr     r3, r3, 4
    orr     r4, r4, r3
    //r3 = BOOKBUF[i]
    mov     r3, 0
    ldrb    r3, [r1, r5]
    //IOBUF[i] = x EOR y
    eor     r4, r4, r3
    strb    r4, [r0, r5]
    //i++
    add     r5, r5, 1
    b .Lloop

.Ldone:
    //return cnt
    mov     r0, r2
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr
    .size encrypt, (. - encrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
