# Brainfuck Interpreter

This project is a small interpreter for the
[Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) programming language
written entirely in x86-64 assembly. It makes syscalls to read code from
standard input and write results to the standard output. As such, it will only
work on x86-64 Linux systems.

Since it expects code to be passed on `stdin`, users cannot give input via
standard input. As such, the `,` Brainfuck command is ignored.

The project was made as an example use case for
[QuickServ](https://github.com/jstrieb/quickserv). Despite this, it has no
security features built in whatsoever. A malicious user can write whatever they
want to the stack, can print whatever they want to the standard output, and is
free to create infinite loops.

Requires a C compiler with a built-in assembler. Tested with `gcc`.