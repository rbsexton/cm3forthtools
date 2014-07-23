((
 Words for MPU work.
))

((
 ------------------------------------------
 System stack tools / Security Changes
 ------------------------------------------
)) 

: psp@ sp_process sys@ ; \ Thread Stack.
: msp@ sp_main sys@    ; \ Exception Stack.

\ Getting into supervisor mode requires us to trap through a syscall.
: threadmode control sys@ 1 or  control sys! ; \ Yield supervisor privs. 
: isthread?  control sys@ 1 and ; \ What state are we in now? 



