module T
  def self.add(n) = n + 1
  BLOCK_LAMBDA = lambda do |a|   # a is Array[String]; add wants Integer
    add(a)
  end
  IT = -> do
    add(it)
  end
end
