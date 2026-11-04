# Precedence and associativity facts the operator table depends on.
# Run: ruby 01_precedence.rb   (developed on ruby 4.0.7)

def show(label, value) = puts("#{label.ljust(28)} #{value.inspect}")

# A negative numeric *literal* binds tighter than **, but unary minus on a
# variable does not.
two = 2
show "-2 ** 2", (-2 ** 2)
show "-two ** 2", (-two ** 2)
show "(-two) ** 2", ((-two) ** 2)
show "2 ** 3 ** 2", (2 ** 3 ** 2)

# ! binds tighter than ==; `not` binds looser than ==, and looser than &&.
show "!true == false", (!true == false)
show "not true == false", (not true == false)

# `and`/`or` bind looser than `=`: a classic.
x = true and false
show "x = true and false; x", x
y = (true && false)
show "y = true && false; y", y

# Equality is non-associative: `a == b == c` is a syntax error.
begin
  eval("1 == 1 == true")
  show "1 == 1 == true", "parsed"
rescue SyntaxError => e
  show "1 == 1 == true", "SyntaxError"
end
# Comparison is left-associative, so a chain parses and then fails at runtime.
begin
  show "1 < 2 < 3", eval("1 < 2 < 3")
rescue NoMethodError => e
  show "1 < 2 < 3", "NoMethodError: #{e.message[/undefined method '[^']+'/]}"
end

# Shifts bind tighter than & which binds tighter than | and ^.
show "1 | 2 & 3", (1 | 2 & 3)
show "1 + 2 << 1", (1 + 2 << 1)
show "6 & 3 == 2", (6 & 3 == 2) rescue show "6 & 3 == 2", "error"

# Integer / and % floor toward negative infinity; Temper truncates.
show "-7 / 2", (-7 / 2)
show "-7 % 2", (-7 % 2)
show "-7.remainder(2)", (-7.remainder(2))
show "7.fdiv(2)", 7.fdiv(2)

# Integers have no width.
show "2 ** 31", 2 ** 31
show "(2**31) class", (2 ** 31).class

# Floats divide by zero without raising.
show "1.0 / 0", 1.0 / 0
show "0.0 / 0", 0.0 / 0
begin
  1 / 0
rescue ZeroDivisionError => e
  show "1 / 0", "ZeroDivisionError"
end
