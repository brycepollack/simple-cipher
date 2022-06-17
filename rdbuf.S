#define MYCODE
#ifdef MYCODE
// version 1.1 05/22/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // global constants
    #include "encrypter.h"

    .section .rodata
.Lmsg:  .string "rdbuf: Bookfile is too short for message\n"
.Lmsg2: .string "rdbuf: Buffer size error\n"
    .text

    //////////////////////////////////////////////////////
    // int rdbuf(char *IOBUF, char *BOOKBUF, FILE *FPIN
    //              FILE *FPBOOK, int BUFSZ);
    // returns number of bytes read EXIT_FAIL otherwise
    //////////////////////////////////////////////////////

    .type   rdbuf, %function
    .global rdbuf
    .equ    IARG5,  4 
    .equ    FP_OFF, 12
 
    ////////////////////////////////////////
    // preserved register use             //
    // r4 pointer to book buffer          //
    // r5 FILE *FPBOOK  & cnt read saved  //
    ////////////////////////////////////////

rdbuf:
    push    {r4, r5, fp, lr}
    add     fp, sp, FP_OFF

    //prep reg for first fread
    mov     r4, 0
    mov     r5, 0
    mov     r5, r3 //r5 = *FPBOOK
    mov     r3, r2 //r3 = *FPIN
    ldr     r4, [fp, IARG5]
    mov     r2, r4 //r2 = bufsz
    mov     r4, r1 //r4 = *BOOKBUF
    mov     r1, 1 //r1 = 1
    
    //if bufsz <= 0, print error
    cmp     r2, 0
    ble     .Lerr1

    //fread(IOBUF, 1, bufsz, FPIN)
    bl     fread
    //if cnt = fread == 0, return cnt
    cmp     r0, 0
    beq     .Lexit

    //prep reg for second fread
    mov     r3, r5 //r3 = FPBOOK
    mov     r5, r0 //r5 = cnt
    mov     r2, r0 //r2 = cnt
    mov     r0, r4 //r0 = BOOKBUF
    mov     r1, 1 //r1 = 1

    //fread(BOOKBUF, 1, cnt, FPBOOK)
    bl      fread

    //if fread != cnt, print error
    cmp     r0, r5
    bne     .Lerr2

    //return cnt
    mov     r0, r5
    b       .Lexit


.Lerr1:
    ldr     r0, =.Lmsg2
    bl      errmsg
    //return EXIT_FAIL
    mov     r0, -1
    b       .Lexit

.Lerr2:
    ldr     r0, =.Lmsg
    bl      errmsg
    //return EXIT_FAIL
    mov     r0, -1

.Lexit:
    sub     sp, fp, FP_OFF
    pop     {r4, r5, fp, lr}
    bx      lr

    .size   rdbuf, (. - rdbuf)
    .section .note.GNU-stack,"",%progbits
.end
#endif
