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
    // int decrypt(char *IOBUF, char *BOOKBUF, int cnt) 
    // decrypts  IOBUF using BOOKBUF; result in IOBUF
    //////////////////////////////////////////////////
    .global decrypt
    .type   decrypt, %function
    .equ    FP_OFF, 12

    ////////////////////////////////////////
    // preserved register use             //
    // r4 IOBUF byte/mask                 //
    // r5 i                               //
    ////////////////////////////////////////

decrypt:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    mov     r4, 0
    mov     r5, 0 //r5: i

.Lloop:
    //if i >= cnt, break
    cmp     r5, r2
    bge     .Ldone

    //r3 = BOOKBUF[i]
    mov     r3, 0
    ldrb    r3, [r1, r5]
    //r4 = IOBUF[i]
    ldrb    r4, [r0, r5]
    //x = x EOR y
    eor     r4, r4, r3
    //x = swap_nibbles
    add     r3, r4, 0
    lsl     r4, r4, 4
    lsr     r3, r3, 4
    orr     r4, r4, r3
    //IOBUF[i] = x
    strb    r4, [r0, r5]
    //i++
    add     r5, r5, 1
    b       .Lloop
 
.Ldone:
    //return cnt
    mov     r0, r2
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size decrypt, (. - decrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
