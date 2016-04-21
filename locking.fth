((
#****h* cm3/getlock
# SYNOPSIS
# 
# USAGE
# addr val -- status
#
# Get a lock using the Cortex-M3 LDREX/STREX primitives.
# Takes in the address of the lock, and returns true
# or false, depending on whether or not the lock was
# a success.   Adapted from the arm docs
#
# On the Stellaris M3/M4 parts, LDREX/STREX will fail if
# an exception slips in there between LDREX and STREX
# 
# This can also be done with bit-banded bits, but LDREX/STREX
# a: don't require the pre-allocation of bits
# b: can use an arbitrary lock value to give you meaningful information about who has the lock.
#***
# Read Arm DHT0008A (ID081709)
# Note that parts with multiple CPUs require a DMB
#
))

CODE GETLOCK \ addr val -- t/f
	 mov r0, tos           \ Save a copy of 'val'
	 ldr tos, [ psp ], # 4 \ Refresh TOS.

L$1:	 ldrex   r1, [ tos ] \ Load the lock value
	 cmp r1, # 0         \ Is the lock free?
	 
	 b .eq L$2           \ If so, jump to the strex
	 clrex               \ Clear the monitor
	 mov tos, # 0 
	 bx LR	            \ Bail.
	
L$2:	strex r2, r0, [ tos ] \ Try and claim the lock
     			      \ 0 is success, 1 is fail.
	 cmp r2, # 0 
	 b .ne L$1 
     	mov tos, # -1
     	next,   
END-CODE

: releaselock ( addr -- )
  0 SWAP ! 
;

(( I Don't know where else to put this. ))
\ Safely read a 64-bit counter.    
CODE D@SAFE
	 str tos, [ psp, # $-04 ] ! \ Push a little
L$3: ldr r0, [ tos, # 4 ] \ Get the MSB
     ldr r1, [ tos, # 0 ] \ LSB
     ldr r2, [ tos, # 4 ] \ Check value
     cmp r0, r2
     b .ne L$3
     str r1, [ psp, # 0 ] 
     mov tos, r0
     next,
END-CODE     
