((
 Wrappers for the REV instruction
 This overlaps with the Cortex Intrinsics, but these can be 
 used at the prompt
))

\ Code to swap between little-endian and big-endian.
CODE REV \ n -- n 
	rev tos, tos
	next,
END-CODE

CODE RBIT \ n -- n 
	rbit tos, tos
	next,
END-CODE

