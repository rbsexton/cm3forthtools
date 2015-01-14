(( 
 idlewfi.fth
 The Sockpuppet system assumes that the CPU wil not be doing 
 unwanted work.   That allows us to use WFI to put it into a 
 low-power mode that will stay that way until there is an interrupt.
 
 This is all required for working IO flow control.
 The basic flow-control system is that back-pressure causes a call to PAUSE
 so that other things can happen.  Eventually we get here, and there is a WFI. 
))


watchdog? [if]
: wfiaction begin [ASM wfi ASM] PAUSE PetWatchDog AGAIN ;
[else] 
: wfiaction begin [ASM wfi ASM] PAUSE AGAIN ;
[then]

\ An advanced word for idle.   Count running tasks, and if
\ its more than 1, do a WFI.
: #RUNNABLE ( -- n )
\ *G Count the running tasks.
  0 self
  begin
    dup tcb.status @ 0<> if swap 1+ swap then
    tcb.link @
    dup self =
  until
  drop
;

;


: IDLEACTION 
  begin
  	pause #runnable 1 = if wfi then 
  again 
;


