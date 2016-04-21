((
Atomic operations for the Cortex-M CPUs.
On Cortem-M3/M4/M7 parts, LDREX/STREX will fail if
an exception happens in between LDREX and STREX

On Cortex-M0, you have to disable interrupts.   That option isn't available
on systems where thread mode tasks run without privileges.

ldrex/strex is relatively cheap.  The only cost is a check and a retry.

Reference: Arm DHT0008A (ID081709)
Note that parts with multiple CPUs require a DMB
))

code +EX!  \ addr val --
\ *G Atomically add val to the contents of addr. 
    mov r0, tos           \ Save a copy of 'val'
    ldr r1,  [ psp ], # 4 \ Refresh TOS.
    ldr tos, [ psp ], # 4 \ empty the stack.
L$1:
    ldrex r2, [ r1 ]
    add r2, r0  
    strex r3, r2, [ r1 ] 
    cmp r3, # 1 
    b .eq L$1
    \ dmb
    next,   
end-code
\ 

code BICEX! \ addr mask -- 
\ *G Atomically clear the mask bits from the contents of addr
    ldr r0, [ psp ], # 4 \ Address
L$1:
    ldrex r1, [ r0 ]
    bic r1, r1, tos
    strex r2, r1, [ r0 ]
    cmp r2, # 0
    b .ne L$1
    \ dmb
    ldr tos, [ psp ], # 4
    next,
end-code

code ORREX! \ addr mask -- 
\ *G Atomically set the mask bits from the contents of addr
    ldr r0, [ psp ], # 4
L$1:
    ldrex r1, [ r0 ]
    orr r1, r1, tos
    strex r2, r1, [ r0 ]
    cmp r2, # 0
    b .ne L$1
    \ dmb
    ldr tos, [ psp ], # 4
    next,
    end-code
