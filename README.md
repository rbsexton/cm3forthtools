cm3forthtools
=============

Cortex-M0/M3/M4 system-level Forth code

Originally for the Cortex-M3, but since expanded
to include support for the Cortex-M0. 

----------
* CortexM0Atomic.fth - Atomic read-modify-writes (Interrupt disabling)
* CortexM0Atomic.fth - Atomic read-modify-writes (LDREX/STREX based)
* aapcs.fth - Arm Architecture Procedure Calling Standards shims for calling C
* bitband.fth - Words for using Cortex-M3 Bit-banding
* cyclecounter.fth - Enabling/Useing the CPU Cycle counter in later M3s
* locking.fth - LDREX/STREX locking primitives and 64-Bit coherent reads.
* nvic.fth - Words for manipulating the NVIC and triggering reset
* pause.fth - Modified MPE Scheduler with support for WFI
* rev.fth - Bit Reverse and Halfword reverse words.
* wfi.fth - Convenience word for using WFI

