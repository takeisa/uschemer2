class SExp
end

class SNilClass < SExp
  def length
    0
  end

  def value
    nil
  end
end

SNil = SNilClass.new

class SCons < SExp
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

class SAtom < SExp
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class SNumber < SAtom
end

class SString < SAtom
end

class SSymbol < SAtom
end
