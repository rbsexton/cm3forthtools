(( 
 -- Code for accessing the ROM routines in the Stellaris/TI
 Cortex-M3s and M4s.
 
 -- Note!  
     -- These tables vary by part.   You must verify
     -- Just declare the offsets as part of the equs.
))

     $01000010 equ ROM_APITABLE
     
     #13 4* equ ROM_SYSCTLTABLE
     #25 4* equ ROM_SysCtlClockGet

     #20 4* equ ROM_MPUTABLE
     #5  4* equ ROM_MPURegionSet
     #6  4* equ ROM_MPURegionGet

     : ROMAddr ( fn-no fn-type -- fn-addr )  ROM_APITABLE + @  swap + @ ;
     (( Example:  ROM_SysCtlClockGet ROM_SYSCTLTABLE ROMAddr )) 

(( There must be some clean way to push a value onto the stack and get it's address ))

     
