Two local lambdas that call each other, the second defined after the
first. Without a forward declaration Ruby reads the later name as a method
call (NameError at runtime). `putter = nil` first runs, and Steep types
`putter` as nil; `nil #: ^(Integer) -> void` is "Assertion cannot hold";
`nil #: untyped` passes and checks nothing. `(_ = nil) #: ^(Integer) ->
void`, an untyped value asserted to the proc type, passes, and
`asserted_forward_checked` shows a call inside the closure is then checked
against that type. be-ruby writes the untyped value as
`TemperCore.forward_reference`.
