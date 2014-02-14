((
 Words for NVIC manipulation from the prompt
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



