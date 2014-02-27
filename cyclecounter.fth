((
	cyclecounter.fth - setup the Cortex-M3 Cycle 
	counter and retrieve data from it 
))

: cyccnt-on \ -- 
	\ Flip the necessary bits 
	\ These two are part of core debug. 
        \ NOTE!  The Cycle counter runs during sleep in 
	\ early revs of the Cortex-M3.  Check the ARM Errata.
	BIT24 $E000EDFC !	\ Set the TRCENA Bit to turn on the DWT
	1 $E0001000  !		\ Whack CYCCNTENA 
;

\ Retreive the current count value
: cyccnt@ \ -- n
	$E0001004 @
; 

\ This is here because I don't know where else to put it.
\ Capture N usage samples and then dump them out for analysis
: captureusage \ n --
    cr
	dup >r  					\ Save a n to the return stack
	0 do getusage #1000 ms loop \ Capture n samples.
  	r>							\ Pop n off the return stack
  	0 do . #44 emit loop		\ Dump out the results with commas
  	cr
  	; 


: usage  
  base @ decimal
  getusage s>d  <# [char] % hold # # [char] . hold #s #> 
  type space base ! ;

