Testing a value of type `T?`, with `T` an unbounded type parameter, for
nil. Steep 2.1 treats an unbounded `T` as having no methods, so `x.nil?` is
an error; `nil == x` (NilClass#==) and `NilClass === x` pass. `nil == s`
does not narrow a `String?`, which translated code does not need, since it
reads a non-null value through `TemperCore.not_null`.
