(
#****h* cm3/semaphore
# SYNOPSIS
# 
# USAGE
# addr val -- 
#
# Add an offset to the contents of an address, using 
# the Cortex-M3 LDREX/STREX primitives.
#
# On the Stellaris M3/M4 parts, LDREX/STREX will fail if
# an exception slips in there between LDREX and STREX
# 
#***
# Read Arm DHT0008A (ID081709)
# Note that parts with multiple CPUs require a DMB
#
))

CODE semaphore-offset \ addr val -- 
	 mov r0, tos           \ Save a copy of 'val'
	 ldr r1,  [ psp ], # 4 \ Refresh TOS.
	 ldr tos, [ psp ], # 4 \ empty the stack.

L$1:	 ldrex r2, [ r1 ] \ Load the lock value
	 add r2, r0  
	 strex r3, r2, [ r1 ] \ Try and claim the lock
     			      \ 0 is success, 1 is fail.
         cmp r3, # 1 
	 b .eq L$1 
     	 next,   
END-CODE

: releaselock ( addr -- )
  0 SWAP ! 
;

