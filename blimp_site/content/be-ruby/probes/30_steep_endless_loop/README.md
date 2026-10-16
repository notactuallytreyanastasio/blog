A method whose `while true` loop ends only by `return`. Ruby runs all
four. Steep 2.1 types the bare loop as nil, and so the method's result;
`loop do`, or an unreachable `raise` or call returning `bot` after the
loop, satisfy it.
