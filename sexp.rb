class SExp
  def atom?
    raise "not implemented yet"
  end
  def list?
    raise "not implemented yet"
  end
end

class SAtom < SExp
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def atom?
    true
  end

  def list?
    false
  end
end

class SNumber < SAtom
end

class SString < SAtom
end

class SSymbol < SAtom
end

class SNilClass < SAtom
  def initialize
  end

  def length
    0
  end

  def value
    nil
  end

  def list?
    true
  end
end

SNil = SNilClass.new

class SCons < SExp
  attr_accessor :car, :cdr

  def initialize(car = SNil, cdr = SNil)
    @car = car
    @cdr = cdr
  end

  def atom?
    false
  end

  def list?
    true
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

