Whether a method's type parameters are in scope in Steep 2.1's inline
annotations. They are not. `#: Array[E]` is "Cannot find type `::E`";
`#: Array[T]` beside a constant `T` means the constant; the older
`@type var` form reads `E` as a constant too. `Array.new` passes, and
checks nothing afterwards (`array_new_checked` pushes a String where an
`E` belongs, without an error). A concrete annotation is checked
(`concrete_checked`).
