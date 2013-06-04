require './vm'
require './instruction'
require './env'
require './sexp'
require './rspec_utils'

include Instruction

describe Halt do
  before do
    @vm = VM.new
  end

  context do
    it { @vm.eval(Halt.new).should eq nil }
  end
end

describe Refer do
  before do
    @vm = VM.new
    bind0 = VarBind.new
    bind0[ssymbol(:a)] = sstring("a_0")
    bind0[ssymbol(:b)] = sstring("b_0")
    bind1 = VarBind.new
    bind1[ssymbol(:a)] = sstring("a_1")
    @vm.e = @vm.e.extend_env(bind0).extend_env(bind1)
  end

  context do
    it {
      operate = Refer.new(ssymbol(:a), Halt.new)
      class_value(@vm.eval(operate)).should eq [SString, "a_1"]
    }
  end

  context do
    it { 
      operate = Refer.new(ssymbol(:b), Halt.new)
      class_value(@vm.eval(operate)).should eq [SString, "b_0"]
    }
  end
end

describe Constant do
  before do
    @vm = VM.new
  end

  context do
    it {
      operate = Constant.new(snumber(123), Halt.new)
      class_value(@vm.eval(operate)).should eq [SNumber, 123]
    }
  end
end

describe Close do
  before do
    @vm = VM.new
    bind0 = VarBind.new
    bind0[ssymbol(:a)] = sstring("a_0")
    bind0[ssymbol(:b)] = sstring("b_0")
    @env = @vm.e = @vm.e.extend_env(bind0)
  end

  context do
    it {
      operate = Close.new([ssymbol(:a), ssymbol(:b)], Return.new, Halt.new)
      ret = @vm.eval(operate)
      ret.is_a?(Closure).should be_true
      ret.body.is_a?(Return).should be_true
      ret.env.should eq @env
    }
  end
end

describe Test do
  before do
    @vm = VM.new
    @operator = Test.new(Constant.new("then", Halt.new),
                         Constant.new("else", Halt.new))
  end

  context do
    it {
      @vm.a = true
      @vm.eval(@operator).should eq "then"
    }
  end
  
  context do
    it {
      @vm.a = false
      @vm.eval(@operator).should eq "else"
    }
  end
end

describe Assign do
  before do
    @vm = VM.new
    @vm.e[ssymbol(:a)] = snumber(0)
    @operator = Constant.new(snumber(1), Assign.new(ssymbol(:a), Halt.new))
  end

  context do
    it {
      class_value(@vm.e[ssymbol(:a)]).should eq [SNumber, 0]
      @vm.eval(@operator)
      class_value(@vm.e[ssymbol(:a)]).should eq [SNumber, 1]
    }
  end
end

describe Conti do
  before do
    @vm = VM.new
    @frame1 = CallFrame.new(nil, nil, nil, @vm.s)
    @vm.s = @frame1
    @operator = Conti.new(Halt.new)
  end

  context do
    it {
      @vm.eval(@operator)
      @vm.a.is_a?(Closure).should be_true
      @vm.a.body.is_a?(Nuate).should be_true
      @vm.a.body.s.should eq @frame1
    }
  end
end

describe Nuate do
  before do
    @vm = VM.new
    @frame1 = CallFrame.new(Halt.new, Env.new, [], @vm.s)
    @frame2 = CallFrame.new(nil, Env.new, [], @frame1)
    @vm.s = @frame2
    @vm.e[ssymbol(:a)] = snumber(1)
    @operator = Nuate.new(@frame1, ssymbol(:a))
  end

  context do
    it {
      @vm.eval(@operator)
      class_value(@vm.a).should eq [SNumber, 1]
    }
  end
end

describe Frame do
  before do
    @vm = VM.new
    @frame1 = CallFrame.new(Halt.new, Env.new, [], @vm.s)
    @vm.s = @frame1
    @vm.e[ssymbol(:a)] = snumber(1)
    @operator = Frame.new(Refer.new(ssymbol(:a), Return.new), Halt.new)
  end

  context do
    it {
      @vm.eval(@operator)
      class_value(@vm.a).should eq [SNumber, 1]
      @vm.s.should eq @frame1
    }
  end
end

describe Argument do
  before do
    @vm = VM.new
    @operator = Constant.new(snumber(1), Argument.new(Constant.new(snumber(2), Argument.new(Halt.new))))
  end

  context do
    it {
      @vm.eval(@operator)
      class_value(@vm.r[0]).should eq [SNumber, 1]
      class_value(@vm.r[1]).should eq [SNumber, 2]
    }
  end
end

describe Apply do
  before do
    @vm = VM.new
    @vm.e[ssymbol(:+)] = lambda {|a, b| a + b}
    @vm.e[ssymbol(:add)] = Closure.new(Frame.new(Refer.new(ssymbol(:a), Argument.new(Refer.new(ssymbol(:b), Argument.new(Refer.new(ssymbol(:+), Apply.new))))), Return.new), @vm.e, SCons.new(ssymbol(:a), SCons.new(ssymbol(:b))))
    @plus_operator = Frame.new(Constant.new(snumber(2), Argument.new(Constant.new(snumber(3), Argument.new(Refer.new(ssymbol(:+), Apply.new))))), Halt.new)
    @closure_operator = Frame.new(Constant.new(snumber(3), Argument.new(Constant.new(snumber(4), Argument.new(Refer.new(ssymbol(:add), Apply.new))))), Halt.new)
  end
  
  context do
    it { class_value(@vm.eval(@plus_operator)).should eq [SNumber, 5] }
  end

  context do
    it { class_value(@vm.eval(@closure_operator)).should eq [SNumber, 7] }
  end

end
