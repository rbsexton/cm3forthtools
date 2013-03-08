\ Wrappers for functions that comply with AAPCS
\
\ Note that these routines push r12, or PSP, as its known by forth.
\ According to AAPCS, thats 'ip', and reserved for use by the linker,
\ which means that AAPCS compliant routines are free to trash it.

\ **********************************************************************
\ Call a function that takes no args, and returns 1.  Push r0 to make
\ the assembler happy.
\ **********************************************************************
CODE call0in1out  ( address -- n )
	\ Easy - Replace TOS.
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE

\ If we pass in a void function, TOS is garbage.   Drop it.
: call0in0out call0in1out drop ; 

\ **********************************************************************
\ Call a function that takes 1 arg and returns 1
\ **********************************************************************
CODE call1in1out \ addr arg0 -- n
	mov r0, tos
	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE

: call1in0out call1in1out drop ;

\ **********************************************************************
\ Call a function that takes 2 args and returns 1
\ **********************************************************************
CODE call2in1out \ addr arg0 arg1 -- n
	mov r1, tos  \ Arg 1
	ldr tos, [ psp ], # 4

	mov r0, tos \ Arg 0

	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE

: call2in0out call2in1out drop ;

\ **********************************************************************
\ Call a function that takes 3 args and returns 1
\ **********************************************************************
CODE call3in1out \ addr arg0 arg1 arg2 -- n
	mov r2, tos  \ Arg 2
	ldr tos, [ psp ], # 4

	mov r1, tos  \ Arg 1
	ldr tos, [ psp ], # 4

	mov r0, tos

	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE

: call3in0out call3in1out drop ;


\ **********************************************************************
\ Call a function that takes 4 args and returns 1
\ **********************************************************************
CODE call4in1out \ addr arg0 arg1 arg2 -- n
	mov r3, tos  \ Arg 3
	ldr tos, [ psp ], # 4

	mov r2, tos  \ Arg 2
	ldr tos, [ psp ], # 4

	mov r1, tos  \ Arg 1
	ldr tos, [ psp ], # 4

	mov r0, tos

	ldr tos, [ psp ], # 4
	orr tos, tos, # 1 \ set Thumb bit
	push { psp, link }
	blx tos
	pop  { psp, link }
	mov tos, r0
	next,
END-CODE

: call4in0out call4in1out drop ;


