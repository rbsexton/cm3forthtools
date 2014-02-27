((
#****h* cm3/bitbandalias
# SYNOPSIS
# Take in an address, and calculate the bitband address of bit 0
# USAGE
# addr -- addr
# 
#***
))

internal 
: bbalias \ addr -- addr
    [ASM L: bbalias ASM] 
    dup $f0000000 and
    $2000000 +
    swap $fffff and #5 lshift +
;
external

((
#****h* cm3/bitband
# SYNOPSIS
# Take in an address and a bit number, and calculate the bitband address.
# USAGE
# bit addr -- addr
#
#***
))


: bitband \ addr bit -- addr 
  #2 lshift swap
  bbalias +
  ;
[then]

