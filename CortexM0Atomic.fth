((
Atomic operations for the Cortex-M CPUs that
make disable interrupts.  

))

: +EX!  \ addr val --
\ *G Atomically add val to the contents of addr.
 [DI swap +!  EI] ; 

: BICEX! \ addr mask -- 
\ *G Atomically clear the mask bits from the contents of addr
 [DI invert over @ and swap !  EI] ;

: ORREX! \ addr mask -- 
\ *G Atomically set the mask bits from the contents of addr
[DI over @ or swap !  EI]
