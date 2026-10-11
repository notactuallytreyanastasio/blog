module M
  # 1. no forward declaration: putter, inside walker, is a method call
  def self.no_forward(x)
    out = [] #: Array[Integer]
    walker = lambda do |i|
      putter.(i) if i < x.length
    end
    putter = lambda do |i|
      out.push(x.fetch(i) * 2)
      walker.(i + 1)
    end
    walker.(0)
    out
  end

  # 2. putter = nil first
  def self.nil_forward(x)
    out = [] #: Array[Integer]
    putter = nil
    walker = lambda do |i|
      putter.(i) if i < x.length
    end
    putter = lambda do |i|
      out.push(x.fetch(i) * 2)
      walker.(i + 1)
    end
    walker.(0)
    out
  end

  # 3. putter = nil, annotated untyped
  def self.untyped_forward(x)
    out = [] #: Array[Integer]
    putter = nil #: untyped
    walker = lambda do |i|
      putter.(i) if i < x.length
    end
    putter = lambda do |i|
      out.push(x.fetch(i) * 2)
      walker.(i + 1)
    end
    walker.(0)
    out
  end

  # 4. putter = nil, annotated with its proc type
  def self.typed_nil_forward(x)
    out = [] #: Array[Integer]
    putter = nil #: ^(Integer) -> void
    walker = lambda do |i|
      putter.(i) if i < x.length
    end
    putter = lambda do |i|
      out.push(x.fetch(i) * 2)
      walker.(i + 1)
    end
    walker.(0)
    out
  end
end
module M
  # 5. the forward value is `_ = nil`, which Steep types untyped, asserted
  # to be the proc type; and a deliberate misuse to show it is checked
  def self.asserted_forward(x)
    out = [] #: Array[Integer]
    putter = (_ = nil) #: ^(Integer) -> void
    walker = lambda do |i|
      putter.(i) if i < x.length
    end
    putter = lambda do |i|
      out.push(x.fetch(i) * 2)
      walker.(i + 1)
    end
    walker.(0)
    out
  end

  def self.asserted_forward_checked
    putter = (_ = nil) #: ^(Integer) -> void
    walker = lambda do |_i|
      putter.("not an Integer")
    end
    putter = lambda do |i|
      i
    end
    walker.(0)
  end
end
[:asserted_forward, :no_forward, :nil_forward, :untyped_forward, :typed_nil_forward].each do |m|
  puts "#{m}: #{(M.send(m, [1, 2, 3]) rescue $!.class)}"
end
