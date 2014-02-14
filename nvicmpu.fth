((
 Words for NVIC manipulation, MPU work, and general system management.
))

: STIR _SCS scsSTIR + ; \ Software Trigger Interrupt reg

\ Whack the APInt register, and do a DSB
\ $05fa0004 _SCS scsAIRCR + ! ; \ Whack the APInt reset bit.

\ Its a bit cleaner to do the infinite loop in assembly.
CODE HWRESET
 	mvl r0, # $05fa0004
 	mvl r1, # $e000ed0c
 	str r0, [ r1, # 0 ]
L$1: b L$1
	next,
END-CODE

(( --------------  Stack Control/Security Changes )) 

: psp@ sp_process sys@ ; \ Thread Stack.
: msp@ sp_main sys@    ; \ Exception Stack.

: threadmode control sys@ 1 or  control sys! ; \ Yield supervisor privs. 


