module N
  def self.a(value)
    raise "null" if value.nil?
    value
  end
  def self.b(value)
    raise "null" if value == nil
    value
  end
  def self.c(value)
    case value
    when nil then raise "null"
    else value
    end
  end
end
