class CallFrame
  # next expression
  attr_accessor :x
  # current environment
  attr_accessor :e
  # current value rib
  attr_accessor :r
  # current stack
  attr_accessor :s

  def initialize(x, e, r, s)
    @x = x
    @e = e
    @r = r
    @s = s
  end
end
