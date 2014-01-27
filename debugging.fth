(( General purpose stuff that is mostly being warehoused here ))

(( Print out a line for testing ))
: .line $7A $30 do I emit loop ;
: lines 0 do I . .line cr loop ;
