module M
  module T
  end

  # 1. inline annotation naming the method's type parameter E
  def self.inline(item)
    items = [] #: Array[E]
    items.push(item)
    items
  end

  # 2. the same, with the parameter called T while a constant T is in scope
  def self.shadowed(item)
    items = [] #: Array[T]
    items.push(item)
    items
  end

  # 3. the older @type var annotation
  def self.type_var(item)
    # @type var items: Array[E]
    items = []
    items.push(item)
    items
  end

  # 4. Array.new, no annotation
  def self.array_new(item)
    items = Array.new
    items.push(item)
    items
  end

  # 5. a generic method whose result type is inferred from the local's later use
  def self.core_builder(item)
    items = new_list_builder
    items.push(item)
    items
  end

  def self.new_list_builder = []

  # 6. inline annotation with a concrete type
  def self.concrete(item)
    items = [] #: Array[Integer]
    items.push(item)
    items
  end
end
p M.inline(1), M.shadowed(2), M.type_var(3), M.array_new(4), M.core_builder(5), M.concrete(6)
module M
  # 7. is the Array.new local typed at all? Push a String where E belongs.
  def self.array_new_checked(item)
    items = Array.new
    items.push("not an E")
    items
  end

  # 8. and the annotated one, pushed a String where Integer belongs
  def self.concrete_checked(item)
    items = [] #: Array[Integer]
    items.push("not an Integer")
    items
  end
end
