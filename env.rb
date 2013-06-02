require './sexp'

class VarBind
  # TODO use vals SCons class
  def initialize(vars = SNil, vals = [])
    @bind = {}
    raise "not equal vars and vals size" unless vars.length == vals.size
    
    index = 0
    until vars == SNil
      @bind[vars.car] = vals[index]
      vars = vars.cdr
      index += 1
    end
  end

  def [](var)
    @bind[var]
  end

  def []=(var, val)
    @bind[var] = val
  end

  def bind?(var)
    @bind.has_key?(var)
  end
end

class Env
  attr_accessor :binds

  def initialize
    @binds = [VarBind.new]
  end

  def extend_env(bind)
    env = Env.new
    env.binds = [bind] + binds
    env
  end

  def [](var)
    bind = find_bind(var)
    return nil if bind.nil?
    bind[var]
  end

  def []=(var, val)
    bind = find_bind(var)
    if bind.nil? then
      bind = @binds[0]
    end
    bind[var] = val
  end

  def set!(var, val)
    bind = find_bind(var)
    raise "not bind #{var}" unless bind
    bind[var] = val
  end

  def find_bind(var)
    @binds.find {|bind| bind.bind?(var)}
  end
end
