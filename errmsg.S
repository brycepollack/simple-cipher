#define MYCODE
#ifdef MYCODE
// version 1.01 05/27/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    // imports
    .extern stderr
    .extern fprintf

    .text

    ////////////////////////////////////////////
    // void errmsg(char *errormsg)            //
    // writes error messages to stderr        //
    ////////////////////////////////////////////
    .type   errmsg, %function
    .global errmsg
    .equ    FP_OFF,  4

errmsg:
    push    {fp, lr}
    add     fp, sp, FP_OFF

    //get parameters ready to pass to fprintf
    mov     r1, r0
    ldr     r0, =stderr
    ldr     r0, [r0]
    //fprintf(stderr, message)
    bl      fprintf
    //return 1
    mov     r0, 1

    sub     sp, fp, FP_OFF
    pop     {fp, lr}
    bx      lr

    .size errmsg, (. - errmsg)
    .section .note.GNU-stack,"",%progbits
.end
#endif
