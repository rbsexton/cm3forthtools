((
#****h* cm3/bitbandalias
# SYNOPSIS
# Take in an address, and calculate the bitband address of bit 0
# USAGE
# addr -- addr
# 
#***
))

[required] bitbandalias [if]
: bitbandalias \ addr -- addr
    dup $f0000000 and
    $2000000 +
    swap $fffff and #5 lshift +
;
[then]

((
#****h* cm3/bitband
# SYNOPSIS
# Take in an address and a bit number, and calculate the bitband address.
# USAGE
# bit addr -- addr
#
#***
))


[required] bitband [if]
: bitband \ addr bit -- addr 
  #2 lshift swap
  bitbandalias +
  ;
[then]

