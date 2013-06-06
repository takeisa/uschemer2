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
* define special form

## Usage

$ ruby uschemer.rb
> (+ 1 2 3)
#<SNumber:0x9f53a08 @value=6>
> ((lambda (a b) (+ a b)) 10 20)
#<SNumber:0x9f58940 @value=30>
> 
