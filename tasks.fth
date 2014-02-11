(( 
 The multitasker on MPE Forth for Cortex-M3
 and tools to work with tasks within that environment.
))

(( 

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

))

\ Take a freshly-created task and fill in the regions to make analysis easier.
$20 equ fill-fence-size
   
: task-fill ( c-addr -- ) DUP
    SP-SIZE - RP-SIZE - DUP    \ Two copies of the bottom of RP.
    RP-SIZE          [char] r fill
    fill-fence-size  [char] x fill \ Do it again.

    DUP SP-SIZE - DUP
    SP-SIZE          [char] d fill
    fill-fence-size  [char] x fill  

    DUP /tcb + UP-SIZE /tcb -                   [char] u fill
    UP-SIZE + fill-fence-size - fill-fence-size [char] x fill
    ;




 
