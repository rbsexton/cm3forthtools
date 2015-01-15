\ An improved scheduler.  Its intended for a system that is interrupt-driven
\ and spends most of it's time asleep waiting for an interrupt that may or
\ may not may not make a task runnable.
\ The typical workload is wfi -> Look for a runnable task -> run it.
\ In a system that mostly waits around a responds to timer ticks, we'll tend
\ to run the same tasks over and over.  So saving state is often a waste of time.

\ This version of the scheduler has mods - 
\ 1.  Counting task runs with a TCB run counter
\ 2.  Using bit-banded addresses for atomic status word updates
\ 3.  It issues a WFI if there are no runnable tasks.
\ 4.  Don't bother doing the single-multi check.
\ 5.  Implement lazy register push.  Only push registers if switching.

\ Switching to this approach from a dedicated idle task resulted in the 
\ same CPU Utilization, but better responsiveness.

CODE pause	\ -- ; the scheduler itself
\ *G The software scheduler itself.
\ Register Usage 
\  R0 Scratch
\  R1 Scratch
\  R5 Status word of current task under consideration
\  R6 Saved UP
\ 
\ l: [schedule]
\  mvl     r0, # ' multi? >body		\ inspect contents of MULTI?
\  ldr     r1, [ r0 ]
\  cmp     r1, # 0			\ single tasking if 0
\  it .eq
\    bx      lr				\ single tasking so exit

  mov r6, up   \ Remember who called PAUSE. 

\
\ select next task to run
\
l: [schedule]next
  ldr     r6, [ r6, # 0 tcb.link ]	\ get next task
  ldr     r5, [ r6, # 0 tcb.status ]	\ inspect status
  cmp     r5, # 0			\ 0 = not running
  b .ne   [schedule]run

  cmp     r6, up \ If we made it around the task list without running, WFI.
  it .eq 
    wfi
  b  [schedule]next

l: [schedule]run

  \ First order of business - If we've circled around, just return
  cmp r6, up
  it .eq 
    bx lr 
  
  \ Save the prior task state
  push    { r7, r9, r12, link }		\ stack used registers ; SFP001
  str     rsp, [ up, # 0 tcb.ssp ]	\ save SP in TCB

  mov up, r6 \ Load up the new task pointer.

  \ We know who it is.   Load up the MPU entries.
  add r0, up, # 0 tcb.mputab   \ Calculate the position of the mpu table.
  svc # SAPI_VEC_MPULOAD       \ Install it.

  ldr r0, [ up, # 0 tcb.runcount ]      \ Bump the run counter 
  add r0, # 1 
  str r0, [ up, # 0 tcb.runcount ]

\
\ run selected task - sp, up, rp, ip
\
  ldr     rsp, [ up, # 0 tcb.ssp ]	\ restore SSP
  pop     { r7, r9, r12, link }		\ restore registers

event-handler? [if]	\ if user wants the event handler
\
\ event handler exit
\
  and .s  r0, r5, # trg-mask		\ inspect event trigger bit
  ne, if,
    ldr     r0, [ up, # 0 tcb.bbstatus ]
    mov     r1, # 0 
    str     r1, [ r0, # trg-bbit# ]    \ clear the trigger bit.
    mov     r1, # 1
    str     r1, [ r0, # evt-bbit# ]    \ set the event bit
    ldr     r1, [ up, # 0 tcb.event ]	\ run event handler
    orr     r1, r1, # 1			\ set Thumb bit
    bx      r1
  endif,
[then]
  next,
end-code
