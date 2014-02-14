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
