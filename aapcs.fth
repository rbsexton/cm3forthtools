\ Wrappers for functions that comply with AAPCS
\
\ General Notes
\
\ All of these words explicitly set the thumb bit.
\ That may or may not be required depending on the link environment.
\ I've opted to do so because its inexpesive to do so, and not doing
\ so could potentially cause a usage fault.
\
\ Cortex-M3/M4 Notes
\ Note that these routines push r12, or PSP, as its known by forth.
\ According to AAPCS, thats 'ip', and reserved for use by the linker,
\ which means that AAPCS compliant routines are free to trash it.
\ These routines don't push r9.  That may be required for calling
\ code compiled with -fpic.
\
\ Cortex-M0 Notes
\ The register layout for the M0 uses r6 for PSP, so there is 
\ no need to preserve it.

\ **********************************************************************
\ Call a function that takes no args, and returns 1.  Push r0 to make
\ the assembler happy.
\ **********************************************************************
Cortex-M0? [if]
CODE CALL0--N ( addr -- n )
	\ Easy - Replace TOS.
	mov .s r0, # 1
	orr .s tos, tos, r0 \ set Thumb bit
	push { link }
	blx tos
	mov tos, r0
	pop { pc }
END-CODE
[else]
CODE CALL0--N ( addr -- n )
	orr tos, tos, #1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE

\ Same thing, for doubles.
CODE CALL0--D ( addr -- d  )
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	str r0, [ psp, # $-04 ] !
	mov tos, r1
	next,
END-CODE
[then]

: CALL0-- call0--n drop ; 

\ **********************************************************************
\ Call a function that takes 1 arg and returns 1
\ **********************************************************************
Cortex-M0? [if]
CODE CALL1--N ( addr arg0 -- n )
	mov r0, tos
	ldr tos, [ psp, # $00 ]
	add .s psp, psp, # 4
	mov .s r5, # 1
	orr .s tos, tos, r5 \ set Thumb bit
	push { link }
	blx tos
	mov tos, r0
	pop  { pc }
END-CODE
[else]
CODE CALL1--N ( addr arg0 -- n )
	mov r0, tos
	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE
[then]
: CALL1-- call1--n drop ; 

\ **********************************************************************
\ Call a function that takes 2 args and returns 1
\ **********************************************************************
Cortex-M0? [if]
[else]
CODE CALL2--N \ addr arg0 arg1 -- n
	mov r1, tos          \ Arg 1
	ldr r0, [ psp ], # 4 \ Arg 0

	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE
: CALL2-- call2--n drop ; 
[then]

\ **********************************************************************
\ Call a function that takes 3 args and returns 1
\ **********************************************************************
Cortex-M0? [if]
CODE CALL3--N \ addr arg0 arg1 arg2 -- n
	mov r2, tos  \ Arg 2
	ldr r1, [ psp, # 0 ] \ Arg 1
	ldr r0, [ psp, # 4 ] \ Arg 0

	ldr tos, [ psp, # 8 ]
	add .s psp, psp, # $c

	mov .s r5, # 1
	orr .s tos, tos, r5 \ set Thumb bit
	push { link }
	blx tos
	mov tos, r0
	pop  { pc }
END-CODE
[else]
CODE CALL3--N \ addr arg0 arg1 arg2 -- n
	mov r2, tos  \ Arg 2
	ldr r1, [ psp ], # 4 \ Arg 1
	ldr r0, [ psp ], # 4 \ Arg 0

	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE
[then]
: CALL3-- call3--n drop ; 

\ **********************************************************************
\ Call a function that takes 4 args and returns 1
\ **********************************************************************
Cortex-M0? [if]
[else]
CODE CALL4--N \ addr arg0 arg1 arg2 arg3 -- n
	mov r3, tos  \ Arg 3
	ldr r2, [ psp ], # 4
	ldr r1, [ psp ], # 4
	ldr r0, [ psp ], # 4

	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE
: CALL4-- call4--n drop ; 
[then]

