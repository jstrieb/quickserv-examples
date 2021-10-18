/***
 * Created by Jacob Strieb
 * July 2021
 */

.global _start

_start:
  /* Make space on the stack for the program memory */
  mov %rsp, %rbp
  sub $30008, %rsp  /* 30000 = 3750 x 8  =>  rsp is address-aligned */


  /* r14 holds the data pointer and r15 holds the code pointer */
  mov %rbp, %r14
  sub $8, %r14
  lea -8(%rsp), %r15


  /* Zero out the Brainfuck program memory 8 bytes at a time */
  mov %rbp, %rdi
.L0:
  sub $8, %rdi
  movq $0, (%rdi)

  cmp %rdi, %rsp
  jne .L0


  /* Read all code from standard input onto the stack (reversed)  */
  sub $8, %rsp
.L1:
  xor %rdi, %rdi    /* stderr is file descriptor 0 */
  mov %rsp, %rsi
  mov $1, %rdx
  xor %rax, %rax    /* SYS_read == 0 */
  syscall
  sub $1, %rsp

  test %eax, %eax
  jnz .L1
  jmp .SWITCH


  /* Increment thet (metaphorical) instruction pointer */
.NEXT_INS:
  sub $1, %r15

  /* If we've reached the end of the code, exit */
.SWITCH:
  cmp %r15, %rsp
  je .EXIT


  /* Switch on the instruction type */
  cmpb $62, (%r15)  /* > */
  je .LEQ
  cmpb $60, (%r15)  /* < */
  je .GEQ
  cmpb $43, (%r15)  /* + */
  je .PLUS
  cmpb $45, (%r15)  /* - */
  je .MINUS
  cmpb $46, (%r15)  /* . */
  je .DOT
  cmpb $44, (%r15)  /* , */
  je .COMMA
  cmpb $91, (%r15)  /* [ */
  je .OPEN
  cmpb $93, (%r15)  /* ] */
  je .CLOSE

  jmp .NEXT_INS       /* Default -- nop for unrecognized characters */


  /* > */
.LEQ:
  sub $1, %r14
  jmp .NEXT_INS


  /* < */
.GEQ:
  add $1, %r14
  jmp .NEXT_INS


  /* + */
.PLUS:
  addb $1, (%r14)
  jmp .NEXT_INS


  /* - */
.MINUS:
  subb $1, (%r14)
  jmp .NEXT_INS


  /* . */
.DOT:
  mov $1, %rdi    /* stdout is file descriptor 1 */
  mov %r14, %rsi
  mov $1, %rdx
  mov $1, %rax    /* SYS_write == 1 */
  syscall
  jmp .NEXT_INS


  /* , */
.COMMA:
  /* nop since we're already reading from stdin */
  jmp .NEXT_INS


  /* [ */
.OPEN:
  mov $1, %rdi
  cmpb $0, (%r14)
  je .L4

  jmp .NEXT_INS

.L4:
  sub $1, %r15
  cmpb $91, (%r15)  /* [ */
  je .L5
  cmpb $93, (%r15)  /* ] */
  je .L6
  jmp .L4

.L5:
  add $1, %rdi
  jmp .L7
.L6:
  sub $1, %rdi
.L7:
  test %rdi, %rdi
  jnz .L4

  jmp .NEXT_INS


  /* ] */
.CLOSE:
  mov $-1, %rdi
  cmpb $0, (%r14)
  jne .L8

  jmp .NEXT_INS

.L8:
  add $1, %r15
  cmpb $91, (%r15)  /* [ */
  je .L9
  cmpb $93, (%r15)  /* ] */
  je .L10
  jmp .L8

.L9:
  add $1, %rdi
  jmp .L11
.L10:
  sub $1, %rdi
.L11:
  test %rdi, %rdi
  jnz .L8

  jmp .NEXT_INS


  /* Exit with code 0 */
.EXIT:
  xor %rdi, %rdi
  mov $60, %rax  /* SYS_exit == 60 */
  syscall
