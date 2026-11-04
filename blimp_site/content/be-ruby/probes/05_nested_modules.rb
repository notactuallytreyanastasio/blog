# `module A::B` needs A to exist already; `module A; module B` makes both.
# And the two spellings resolve constants differently. Run: ruby 05_nested_modules.rb
def show(label, value) = puts("#{label.ljust(40)} #{value.inspect}")

begin
  eval("module Outer::Inner; end")
  show "module Outer::Inner (no Outer)", "defined"
rescue NameError => e
  show "module Outer::Inner (no Outer)", "NameError: #{e.message}"
end

module Outer
  X = "Outer::X"
  module Inner; end
end

# Nested spelling: lexical scope includes Outer, so X resolves.
module Outer
  module Inner
    show "nested: X inside Inner", X
  end
end

# Compact spelling: lexical scope is Outer::Inner only, so X does not.
module Outer::Inner
  begin
    show "compact: X inside Outer::Inner", X
  rescue NameError => e
    show "compact: X inside Outer::Inner", "NameError"
  end
end
