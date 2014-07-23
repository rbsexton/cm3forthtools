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


(( ----------------------------------------------------------------------------- 
   MPU Tools 
   ----------------------------------------------------------------------------- ))

_SCS $D90 + equ _MPU

: (tcb.mputab) tcb.mputab ;
: rba2addr $1f invert AND ;

: mpuget ( n -- addr attr ) >R  _MPU
  dup $8 + R> swap !
  dup $C + @ swap $10 + @ ; 
: mpudump $8 0 do I mpuget . . cr loop ;

\ A Sup RW User RO 32b area, enabled.
$2000009 equ mpu32b_rofence 


: fillmpuslots ( 4..n c-addr -- ) $20 bounds DO I ! 8 +LOOP ; 
: assignregions ( c-addr ) 4 0 DO DUP I 2+ $10 OR SWAP +! 8 + LOOP DROP ;  
: attrlist mpu32b_rofence dup 2dup ; 

