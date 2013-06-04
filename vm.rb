require './instruction'
require './frame'
require './env'

class VM
  # accumulator
  attr_accessor :a
  # next expression
  attr_accessor :x
  # current environment
  attr_accessor :e
  # current value rib
  attr_accessor :r
  # current stack
  attr_accessor :s

  def initialize
    @a = nil
    @x = nil
    @e = Env.new
    @r = []
    @s = nil
  end

  def eval(operator)
    @x = operator
    while true do
      if @x.nil? then
        return @a
      end
#puts @x
      @x.eval(self)
    end
  end
end
