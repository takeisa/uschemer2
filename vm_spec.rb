require './vm'
require './instruction'
require './env'

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
    bind0[:a] = "a_0"
    bind0[:b] = "b_0"
    bind1 = VarBind.new
    bind1[:a] = "a_1"
    @vm.e = @vm.e.extend_env(bind0).extend_env(bind1)
  end

  context do
    it {
      operate = Refer.new(:a, Halt.new)
      @vm.eval(operate).should eq "a_1"
    }
  end

  context do
    it { 
      operate = Refer.new(:b, Halt.new)
      @vm.eval(operate).should eq "b_0"
    }
  end
end

describe Constant do
  before do
    @vm = VM.new
  end

  context do
    it {
      operate = Constant.new(123, Halt.new)
      @vm.eval(operate).should eq 123
    }
  end
end

describe Close do
  before do
    @vm = VM.new
    bind0 = VarBind.new
    bind0[:a] = "a_0"
    bind0[:b] = "b_0"
    @env = @vm.e = @vm.e.extend_env(bind0)
  end

  context do
    it {
      operate = Close.new([:a, :b], Return.new, Halt.new)
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
    @vm.e[:a] = 0
    @operator = Constant.new(1, Assign.new(:a, Halt.new))
  end

  context do
    it {
      @vm.e[:a].should eq 0
      @vm.eval(@operator)
      @vm.e[:a].should eq 1
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
    @vm.e[:a] = 1
    @operator = Nuate.new(@frame1, :a)
  end

  context do
    it {
      @vm.eval(@operator)
      @vm.a.should eq 1
    }
  end
end

describe Frame do
  before do
    @vm = VM.new
    @frame1 = CallFrame.new(Halt.new, Env.new, [], @vm.s)
    @vm.s = @frame1
    @vm.e[:a] = 1
    @operator = Frame.new(Refer.new(:a, Return.new), Halt.new)
  end

  context do
    it {
      @vm.eval(@operator)
      @vm.a.should eq 1
      @vm.s.should eq @frame1
    }
  end
end

describe Argument do
  before do
    @vm = VM.new
    @operator = Constant.new(1, Argument.new(Constant.new(2, Argument.new(Halt.new))))
  end

  context do
    it {
      @vm.eval(@operator)
      @vm.r.should eq [1, 2]
    }
  end
end

describe Apply do
  before do
    @vm = VM.new
    @vm.e[:+] = lambda {|a, b| a + b}
    @vm.e[:add] = Closure.new(Frame.new(Refer.new(:a, Argument.new(Refer.new(:b, Argument.new(Refer.new(:+, Apply.new))))), Return.new), @vm.e, SCons.new(:a, SCons.new(:b)))
    @plus_operator = Frame.new(Constant.new(2, Argument.new(Constant.new(3, Argument.new(Refer.new(:+, Apply.new))))), Halt.new)
    @closure_operator = Frame.new(Constant.new(3, Argument.new(Constant.new(4, Argument.new(Refer.new(:add, Apply.new))))), Halt.new)
  end
  
  context do
    it { @vm.eval(@plus_operator).should eq 5 }
  end

  context do
    it { @vm.eval(@closure_operator).should eq 7 }
  end

end
