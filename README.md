uschemer2
=========

Micro Scheme on Ruby 2

Implements based on Three Implementation Models for Scheme (http://www.cs.indiana.edu/~dyb/papers/3imp.pdf).

## Implemented

* Scheme Virtual machine
* Compiler
* Continuation
* REPL

## Not implemented yet

* Tail call optimization

## Support primitive functions
Only + - * /

## Usage

    $ ruby uschemer.rb
    Micro Scheme
    > (define (add a b) (+ a b))
    #<Instruction::Closure:0x98295fc>
    > (add 10 20)
    30
    > 
