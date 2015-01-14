\ This version of the scheduler has three mods - 
\ Counting task runs with a TCB run counter
\ Using bit-banded addresses for atomic status word updates
\ It issues a WFI if there are no runnable tasks.

CODE pause	\ -- ; the scheduler itself
\ *G The software scheduler itself.
l: [schedule]
  mvl     r0, # ' multi? >body		\ inspect contents of MULTI?
  ldr     r1, [ r0 ]
  cmp     r1, # 0			\ single tasking if 0
  it .eq
    bx      lr				\ single tasking so exit
\
\ Save the task state
\
  push    { r7, r9, r12, link }		\ stack used registers ; SFP001
  str     rsp, [ up, # 0 tcb.ssp ]	\ save SP in TCB

  mov r2, up   \ Remember.  We will loop around the task ring.
\
\ select next task to run
\
l: [schedule]next
  ldr     up, [ up, # 0 tcb.link ]	\ get next task
  ldr     r3, [ up, # 0 tcb.status ]	\ inspect status
  cmp     r3, # 0			\ 0 = not running
  b .ne   [schedule]run

  cmp     up, r4 \ If we made it around the ring without running, WFI.
  it .eq 
    wfi
  b  [schedule]next

l: [schedule]run

  \ We know who it is.   Load up the MPU entries.
  add r0, up, # 0 tcb.mputab   \ Calculate the position of the mpu table.
  svc # SAPI_VEC_MPULOAD       \ Install it.

  ldr r1, [ up, # 0 tcb.runcount ]      \ Bump the run counter 
  add r1, # 1 
  str r1, [ up, # 0 tcb.runcount ]

\
\ run selected task - sp, up, rp, ip
\
  ldr     rsp, [ up, # 0 tcb.ssp ]	\ restore SSP
  pop     { r7, r9, r12, link }		\ restore registers

event-handler? [if]	\ if user wants the event handler
\
\ event handler exit
\
  and .s  r1, r3, # trg-mask		\ inspect event trigger bit
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
