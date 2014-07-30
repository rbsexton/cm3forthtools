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

CODE getlock \ addr val -- t/f
	 mov r1, tos       \ Initialize the 'lock taken' value
	 mov r2, # 1		   \ A handy constant
	 ldr tos, [ psp ], # 4 \ Now that TOS is r1, pop it off
	 ldrex   r0, [ tos ] \ Load the lock value
	 cmp r0, # 0         \ Is the lock free?
	 b .eq L$1           \ If so, jump to the strex
	 mov tos, # 0        \ Return fail.
	 bx LR	            \ Bail.
	
L$1: strex tos, r1, [ tos ] \ Try and claim the lock
     \ 0 is success, 1 is fail.
     mov tos, # 0 
     sub tos, r1  \ Subtract 1 to get forth-standard conventions 
     next,   
END-CODE

: releaselock ( addr -- )
  0 SWAP ! 
;

