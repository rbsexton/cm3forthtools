((
   Atomic operations for the Cortex-M CPUs.
   Setup for use as a library.

   This code contains embedded assembly.
   Library code seems to be badly suited for inlining.
))

[required] +EX! [if]
: +EX!  \ addr val --
\ *G Atomically add val to the contents of addr.
 swap [asm cps .id .i asm] +! [asm cps .ie .i asm] ; 
[then]

[required] BICEX! [if]
: BICEX! \ addr mask -- 
\ *G Atomically clear the mask bits from the contents of addr
 invert over [asm cps .id .i asm] @ and swap ! [asm cps .ie .i asm] ;
[then]

[required] ORREX! [if]
: ORREX! \ addr mask -- 
\ *G Atomically set the mask bits from the contents of addr
  over [asm cps .id .i asm] @ or swap ! [asm cps .ie .i asm] ;
[then]

[required] @OFFEX! [if]
: @OFFEX! \ addr -- n 
\ *G Atomically retrieve and clear a semaphore value.
  0 swap  dup [asm cps .id .i asm] @ >R ! R> [asm cps .ie .i asm] ; 
[then]
