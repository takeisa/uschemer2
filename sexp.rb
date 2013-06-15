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
  def to_s
    @value
  end
end

class SString < SAtom
  def to_s
    %Q("#{@value}")
  end
end

class SSymbol < SAtom
  def to_s
    @value.to_s
  end
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

  def to_s
    "nil"
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

  def to_s(need_paren = true)
    s = ""
    s << "(" if need_paren
    s << "#{@car.to_s}"
#    print "car=#{@car} class=#{@car.class} value=#{@car.to_s} s=#{s}\n"
    if @cdr == SNil then
      # nop
    elsif @cdr.list? then
      s << " #{@cdr.to_s(false)}"
    else
      s << " . #{@cdr.to_s}"
    end
    s << ")" if need_paren
    s
  end
end

