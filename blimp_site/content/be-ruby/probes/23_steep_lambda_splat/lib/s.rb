module S
  def self.count(list) = list.length
  STABBY = ->(a) do              # 0: the one Steep splats
    count(a)
  end
  ANNOTATED = ->(a) do           # 0b: an annotation cannot override it
    # @type var a: Array[String]
    count(a)
  end
  BLOCK_LAMBDA = lambda do |a|   # 1
    count(a)
  end
  NUMBERED = -> do               # 2
    count(_1)
  end
  IT = -> do                     # 3
    count(it)
  end
  TO_PROC = method(:count).to_proc  # 4
  WITH_DEFAULT = ->(a, _ = nil) do  # 5
    count(a)
  end
end
p [S::STABBY, S::ANNOTATED, S::BLOCK_LAMBDA, S::NUMBERED, S::IT, S::TO_PROC, S::WITH_DEFAULT].map { _1.(%w[x y]) }
