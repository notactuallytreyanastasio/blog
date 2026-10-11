module M
  # 1. the loop exits only by return
  def self.bare_while(n)
    i = 0
    while true
      return "found #{i}" if i == n

      i += 1
    end
  end

  # 2. Kernel#loop, which RBS declares as returning bot
  def self.loop_do(n)
    i = 0
    loop do
      return "found #{i}" if i == n

      i += 1
    end
  end

  # 3. an unreachable raise after the loop
  def self.while_then_raise(n)
    i = 0
    while true
      return "found #{i}" if i == n

      i += 1
    end
    raise "unreachable"
  end

  # 4. an unreachable call declared to return bot
  def self.while_then_panic(n)
    i = 0
    while true
      return "found #{i}" if i == n

      i += 1
    end
    panic
  end

  def self.panic = raise("panic")
end
p M.bare_while(3), M.loop_do(3), M.while_then_raise(3), M.while_then_panic(3)
