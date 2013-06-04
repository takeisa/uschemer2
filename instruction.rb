require 'pp'

module Instruction
  class Operator
    def eval(vm)
      raise "not implemented"
    end
  end
  
  class Halt < Operator
    def eval(vm)
      vm.x = nil
    end

    def to_s
      "(halt)"
    end
  end
  
  class Refer < Operator
    def initialize(var, x)
      @var = var
      @x = x
    end
    
    def eval(vm)
      vm.a = vm.e[@var]
# pp vm.e
# puts "-> #{vm.a}"
      vm.x = @x
    end
    
    def to_s
      "(refer #{@var})"
    end
  end
  
  class Constant < Operator
    def initialize(obj, x)
      @obj = obj
      @x = x
    end
    
    def eval(vm)
      vm.a = @obj
      vm.x = @x
    end
    
    def to_s
      "(constant #{@obj})"
    end
  end

  class Close < Operator
    def initialize(vars, body, x)
      @vars = vars
      @body = body
      @x = x
    end
    
    def eval(vm)
      vm.a = Closure.new(@body, vm.e, @vars)
      vm.x = @x
    end

    def to_s
      "(close #{@vars} #{@body})"
    end
  end

  class Test < Operator
    def initialize(a_then, a_else)
      @then = a_then
      @else = a_else
    end

    def eval(vm)
      vm.x = vm.a ? @then : @else
    end

    def to_s
      "(test #{@then} #{@else})"
    end
  end

  class Assign < Operator
    def initialize(var, x)
      @var = var
      @x = x
    end

    def eval(vm)
      vm.e.set!(@var, vm.a)
      vm.x = @x
    end

    def to_s
      "(assign #{@var})"
    end
  end

  class Conti < Operator
    def initialize(x)
      @x = x
    end

    def eval(vm)
      vm.a = continuation(vm.s)
      vm.x = @x
    end

    def continuation(s)
      Closure.new(Nuate.new(s, SSymbol.new(:v)), Env.new, SCons.new(SSymbol.new(:v)))
    end

    def to_s
      "(conti)"
    end
  end

  class Nuate < Operator
    attr_accessor :s, :var
    
    def initialize(s, var)
      @s = s
      @var = var
    end

    def eval(vm)
      vm.a = vm.e[@var]
      vm.s = @s
      vm.x = Return.new
    end

    def to_s
      "(nuate #{@s} #{var})"
    end
  end

  class Frame < Operator
    def initialize(x, ret)
      @x = x
      @ret = ret
    end

    def eval(vm)
      vm.s = CallFrame.new(@ret, vm.e, vm.r, vm.s)
      vm.x = @x
      vm.r = []
    end

    def to_s
      "(frame)"
    end
  end

  class Argument < Operator
    def initialize(x)
      @x = x
    end

    def eval(vm)
      # use r register SCons class
      vm.r = vm.r + [vm.a]
      vm.x = @x
    end

    def to_s
      "(argument)"
    end
  end

  class Apply < Operator
    def eval(vm)
      if vm.a.is_a?(Proc) then
        rb_objs = exp_to_rb_obj(vm.r)
        res = vm.a.call(*rb_objs)
        vm.a = rb_obj_to_exp(res)
        vm.x = Return.new
      elsif vm.a.is_a?(Closure) then
        closure = vm.a
        vm.x = closure.body
#puts "***extend_env"
#pp closure.vars
#pp vm.r
#pp vm.e
        vm.e = closure.env.extend_env(VarBind.new(closure.vars, vm.r))
#pp vm.e
        vm.r = []
      else
        raise "not function"
      end
    end

    def exp_to_rb_obj(exps)
      rb_objs = []
      exps.each do |exp|
        rb_objs << exp.value
      end
      rb_objs
    end

    def rb_obj_to_exp(rb_obj)
      if rb_obj.is_a?(Numeric) then
        SNumber.new(rb_obj)
      elsif rb_obj.is_a?(String) then
        SString.new(rb_obj)
      elsif rb_obj.is_a?(Symbol) then
        SString.new(rb_obj)
      else
        raise "not support object (class:#{rb_obj.class})"
      end
    end

    def to_s
      "(apply)"
    end
  end

  class Return < Operator
    def eval(vm)
      s = vm.s
      vm.x = s.x
      vm.e = s.e
      vm.r = s.r
      vm.s = s.s
    end

    def to_s
      "(return)"
    end
  end

  class Closure
    attr_accessor :body, :env, :vars

    def initialize(body, env, vars)
      @body = body
      @env = env
      @vars = vars
    end
  end

  class Continuation
    attr_accessor :s

    def initialize(s)
      @s = s
    end
  end
end
