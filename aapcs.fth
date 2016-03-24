\ Wrappers for functions that comply with AAPCS
\
\ Note that these routines push r12, or PSP, as its known by forth.
\ According to AAPCS, thats 'ip', and reserved for use by the linker,
\ which means that AAPCS compliant routines are free to trash it.
\ These routines don't push r9.   Thats may be required for calling
\ code compiled with -fpic.

\ **********************************************************************
\ Call a function that takes no args, and returns 1.  Push r0 to make
\ the assembler happy.
\ **********************************************************************
CODE CALL0--N ( addr -- n )
	\ Easy - Replace TOS.
	orr tos, tos, # 1 \ set Thumb bit
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

\ **********************************************************************
\ Call a function that takes 1 arg and returns 1
\ **********************************************************************
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

\ **********************************************************************
\ Call a function that takes 2 args and returns 1
\ **********************************************************************
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

\ **********************************************************************
\ Call a function that takes 3 args and returns 1
\ **********************************************************************
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

\ **********************************************************************
\ Call a function that takes 4 args and returns 1
\ **********************************************************************
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

\ **********************************************************************
\ Wrappers for functions with no returns.
\ **********************************************************************
: CALL0-- call0--n drop ; 
: CALL1-- call1--n drop ; 
: CALL2-- call2--n drop ; 
: CALL3-- call3--n drop ; 
: CALL4-- call4--n drop ; 

