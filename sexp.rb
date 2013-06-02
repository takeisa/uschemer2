class SNilClass
  def length
    0
  end
end

SNil = SNilClass.new

class SCons
  attr_accessor :car, :cdr

  def initialize(car = SNil, cdr = SNil)
    @car = car
    @cdr = cdr
  end

  def length
    len = 1
    cons = self
    until cons.cdr == SNil
      len += 1
      cons = cons.cdr
      raise "The value #{cons} is not of type list." unless cons.is_a?(SCons)
    end
    len
  end
end
