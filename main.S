#define MYCODE
#ifdef MYCODE
// version 1.1 05/27/2022
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // function import
    .extern encrypt
    .extern decrypt
    .extern setup
    .extern rdbuf
    .extern cleanup
    .extern wrbuf

    // global constants
    #include "encrypter.h"

    .text

    //////////////////////////////////////////////////////
    // int main(int argc, char **argv)                  //
    // encrypter [-d | -e] -b bookfile encryption_file  //
    //////////////////////////////////////////////////////

    .global main
    .type   main, %function
    .equ    BUFSZ,      1024          // buffer size
    .equ    FP_OFF,     28            // fp offset in main stack frame
    .equ    FPBOOK,     4 + FP_OFF    // FILE * to book file
    .equ    FPIN,       4 + FPBOOK    // FILE * to input file
    .equ    FPOUT,      4 + FPIN      // FILE * to output file
    .equ    MODE,       4 + FPOUT     // decrypt or encrypt mode
    .equ    IOBUF,      BUFSZ + MODE  // buffer for input file
    .equ    BOOKBUF,    BUFSZ + IOBUF // buffer for book file
    //add local variables here: adjust PAD size
    .equ    PAD,        BOOKBUF       // Stack frame PAD 
    .equ    OARG6,      4 + PAD       // output arg6
    .equ    OARG5,      4 + OARG6     // output arg5
    .equ    FRAMESZ,    OARG5-FP_OFF// total space for frame
 
    ////////////////////////////////////////
    // preserved register use             //
    // r4 pointer to input/output buffer  //
    // r5 pointer to book buffer          //
    // r6 mode flag                       //
    // r7 input FILE *                    //
    // r8 book FILE *                     //
    // r9 output FILE *                  //
    ////////////////////////////////////////

main:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF          // set frame pointer to frame base
    ldr     r3, =FRAMESZ            // frame size is big, use pseudo ldr
    sub     sp, sp, r3              // allocate space for locals and passed args 
     
    // call int setup(argc, argv, *mode, *FPBOOK, *FPIN, *FPOUT)
    add     r7, fp, -FPIN
    add     r9, fp, -FPOUT
    str     r9, [fp, -OARG6]
    str     r7, [fp, -OARG5]
    ldr     r3, =FPBOOK
    sub     r3, fp, r3
    ldr     r2, =MODE
    sub     r2, fp, r2

    bl      setup
    cmp     r0, -1
    beq     .Ldone

    //set up for main loop
    mov     r4, 0
    mov     r5, 0
    mov     r6, 0
    mov     r7, 0
    mov     r8, 0
    mov     r9, 0
    add     r6, fp, -MODE
    ldr     r6, [r6]
    add     r7, fp, -FPIN
    ldr     r7, [r7]
    add     r8, fp, -FPBOOK
    ldr     r8, [r8]
    add     r9, fp, -FPOUT
    ldr     r9, [r9]

    ldr     r4, =IOBUF
    sub     r4, fp, r4
    ldr     r5, =BOOKBUF
    sub     r5, fp, r5

.Lloop:
    //zero out scratch registers
    mov     r0, 0
    mov     r1, 0
    mov     r2, 0
    mov     r3, 0
    //set up for call to rdbuf
    mov     r0, BUFSZ
    str     r0, [fp, -OARG5]
    mov     r3, r8 //r3 = *FPBOOK
    mov     r2, r7 //r2 = *FPIN
    mov     r1, r5 //r1 = *BOOKBUF
    mov     r0, r4 //r0 = *IOBUF
    //cnt = rdbuf(char *IOBUF, char *BOOKBUF, FILE *FPIN
    //              FILE *FPBOOK, int BUFSZ)
    bl      rdbuf
    //if cnt <= 0, break
    cmp     r0, 0
    ble     .Ldone
    //if flag != 1, decrypt
    cmp     r6, 1
    bne     .Ldecrypt

.Lprocinput:
    mov     r2, r0
    mov     r1, r5
    mov     r0, r4
    //int encrypt(char *IOBUF, char *BOOKBUF, int cnt)
    bl      encrypt
    b       .Lwriteout

.Ldecrypt:
    mov     r2, r0
    mov     r1, r5
    mov     r0, r4
    //int decrypt(char *IOBUF, char *BOOKBUF, int cnt)
    bl      decrypt
    b       .Lwriteout

.Lwriteout:
    //if cnt == -1, break
    cmp     r0, -1
    beq     .Ldone
    mov     r2, r9
    mov     r1, r0
    mov     r0, r4
    //int wrbuf(char *IOBUF, int cnt, FILE *FPOUT);
    bl      wrbuf
    //if cnt != -1, loop again
    cmp     r0, -1
    bne     .Lloop
    //return cnt

.Ldone:
    // int cleanup(int status)
    // r0 should have exit status in it
    bl      cleanup

.Lexit:
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size   main, (. - main)
    .section .note.GNU-stack,"",%progbits
.end
#endif
