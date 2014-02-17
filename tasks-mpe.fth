(( 
 The multitasker on MPE Forth for Cortex-M3
 and tools to work with tasks within that environment.
))

(( ----------------------------------------------------------------------------- 

The task consists of User, Data Stack, and Return Stack.

The stackdef code defines things for the initial task.
init-u0 . 20010C00  ok <- Grows Up.
init-s0 . 20010C00  ok <- Grows Down
init-r0 . 20010B00  ok <- Grows Down

Ideally, you'd use a stack fence at the bottom of the return stack and the data stack, and
on top of the user area.   That should catch most over-under-runs before things get ugly.

I'm not sure how to make the MPU do something graceful, as we have no page fault mechanisms.

-- Aligning Tasks 

Compile-time tasks are allocated via reserve, which grows down
Run-time tasks are allocated from the dictionary (via here), which grows up.

RESERVE is what allocates task blocks at compile-time.   It grows
down, so thats simpler.  Just reserve the right amount to force it to
a boundary.

------------------------------------------------------------------------------- ))

: alignhere ( n -- ) DUP DUP 1 - HERE AND -   SWAP MOD ALLOT ; \ Power of two required.
: align32 ( -- ) $20 alignhere ;  

\ Word-Based fill.  A little funny because it mimics the semantics of (c)fill
: lfill ( addr n k -- ) -ROT bounds do DUP I ! 4 +loop DROP ;

\ Take a freshly-created task and fill in the regions to make analysis easier.
$20 equ fill-fence-size
up-size /tcb - equ up-free

: task-limits ( c-addr -- rbot sbot utop )
   TASK-S0 - 
   DUP rp-size + 
   DUP sp-size + up-size +
   ;
  
(( Filling and fencing are separate.   Its not safe to fill a running task ))

: makefence ( c-addr ) fill-fence-size  $2170615a lfill ;
: task-fence ( caddr ) task-limits 
   fill-fence-size - makefence
   makefence
   makefence
; 

: task-fill ( c-addr -- ) task-limits
   up-free - up-free $20552020 lfill 
   sp-size $20442020 lfill
   rp-size $20522020 lfill
   ;

: taskdump ( c-addr ) TASK-S0 - $80 - TASK-S0 up-size + $80 + ldump ; \ Don't overrun memory.  Thats bad.

(( ----------------------------------------------------------------------------- 
   Tools for working with priveleged/user mode.  Note that there is no 
   way for a user mode task to become priv'd, so that has to be done via SVC.
   ----------------------------------------------------------------------------- ))

: usermode CONTROL sys@ 1 OR CONTROL sys! ;
\ Privmode is part of SAPI.      

(( ----------------------------------------------------------------------------- 
   MPU Tools 
   ----------------------------------------------------------------------------- ))

_SCS $D90 + equ _MPU

: mpuget ( n -- addr attr ) >R  _MPU
  dup $8 + R> swap !
  dup $C + @ swap $10 + @ ; 
: mpudump $8 0 do I mpuget . . cr loop ; 