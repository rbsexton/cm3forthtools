\ An improved scheduler.  Its intended for a system that is interrupt-driven
\ and spends most of it's time asleep waiting for an interrupt that may or
\ may not may not make a task runnable.
\ The typical workload is wfi -> Look for a runnable task -> run it.
\ In a system that mostly waits around a responds to timer ticks, we'll tend
\ to run the same tasks over and over.  So saving state is often a waste of time.

\ This version of the scheduler has mods - 
\ 1.  Counting task runs with a TCB run counter
\ 3.  It issues a WFI if there are no runnable tasks.
\ 4.  Don't bother doing the single-multi check.
\ 5.  Implement lazy register push.  Only push registers if switching.

\ Switching to to integrated WFI resulted in the same CPU Utilization with
\ better responsiveness.   Lazy register push is a win.

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

  mov r6, up   \ Use r6 as the working copy of the UP.

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

  \ ---------------------------------------------------
  \ Do any MPU task updates here.
  \ ---------------------------------------------------
  \ This is where task accounting goes.  Counters, etc.
  \ ---------------------------------------------------
\
\ run selected task - sp, up, rp, ip
\
  ldr     rsp, [ up, # 0 tcb.ssp ]	\ restore SSP
  pop     { r7, r9, r12, link }		\ restore registers

event-handler? [if]	\ if user wants the event handler
\
\ event handler exit
\ Note that r5 still contains the status word.
\
  and .s  r0, r5, # trg-mask		\ inspect event trigger bit
  ne, if,

	mov r0, # evt-mask
	mov r1, # trg-mask

[defined] irqsafe-usermode? [if] \ Do this atomically with ldrex/strex
l: [evthandler]ldrex
	ldrex   r2, [ up, # 0 tcb.status ]
	bic     r2, r2, r0 \ clear the trigger bit.
	orr     r2, r2, r1 \ set the event bit
	strex   r3, r2, [ up, # 0 tcb.status ]
	cmp     r3, # 0
	b .ne  [evthandler]ldrex
	dmb # 0 \ per ARM docs
[else] \ If the task is running with privs, it can disable irqs.
	cps  .id 
 	ldr   r2, [ up, # 0 tcb.status ]
	bic   r2, r2, r0 \ clear the trigger bit.
	orr   r2, r2, r1 \ set the event bit
	str   r2, [ up, # 0 tcb.status ]
	cps .ie
[then]
    ldr     r1, [ up, # 0 tcb.event ]	\ run event handler
    orr     r1, r1, # 1			\ set Thumb bit
    bx      r1
  endif,
[then]
  next,
end-code

\ This has to match the scheduler, above.
code init-task	\ xt task -- ; Initialise a task stack
\ *G Initialise a task's stack before running it and
\ ** set it to execute the word whose XT is given.
  ldr     r1, [ psp ], # 4		\ get execution address
  orr     r1, r1, # 1			\ set Thumb bit
  mov     r2, rsp			\ save return stack pointer

\ Generate the RSP of the new task
\ the next line works because TASK-U0 is greater than TASK-R0
  sub     rsp, tos, # task-u0 task-r0 -	\ generate new task RSP

  mov     r0, # 0			\ will need this many times

  str     rsp, [ tos, # r0-offset ]	\ save new R0 (taskID=UP)
  str     r0, [ tos, # 0 tcb.status ]	\ clear new task status

  push    { r1 }			\ R14 LINK, push xt=link
\ the next line works because TASK-U0 is greater than TASK-S0
  sub     r1, tos, # task-u0 task-s0 -	\ calculate new PSP
  sub	  r1, r1, # sp-guard cells	\ generate new PSP ; SFP003
  push    { r1 }			\ R12, new PSP ; SFP003
  sub	  r1, r1, # tos-cached? cells	\ generate new S0 ; SFP003
  str     r1, [ tos, # s0-offset ]	\ that is compatible with SP!
  push    { r0 }			\ R9
  push    { r0 }			\ R7, new TOS for Cortex
  str     rsp, [ tos, # 0 tcb.ssp ]	\ save RSP

  mov     rsp, r2			\ restore RSP
  ldr     tos, [ psp ], # 4		\ restore TOS
  next,
end-code



