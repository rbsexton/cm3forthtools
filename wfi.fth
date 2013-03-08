(( 
 This is a library call.   Sadly, MPE has no WFI intrinsic, so I just made a word.
))

[required] wfi [if]
CODE wfi  \ --
	wfi
	next,
END-CODE
[then]

