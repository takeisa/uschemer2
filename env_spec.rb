require './env'
require './sexp'

describe VarBind do
  before do
    @bind = VarBind.new
    @bind[:a] = "a"
    @bind[:b] = nil
  end

  context do
    it { @bind[:a].should eq "a" }
  end

  context do
    it { @bind[:b].should eq nil }
  end

  context do
    it { @bind[:undefined].should eq nil }
  end

  context do
    it { @bind.bind?(:a).should eq true }
  end

  context do
    it { @bind.bind?(:b).should be_true }
  end

  context do
    it { @bind.bind?(:undefined).should be_false }
  end

  context do
    it {
      bind = VarBind.new(SCons.new(:a, SCons.new(:b)), [1, 2])
      bind[:a].should eq 1
      bind[:b].should eq 2
    }
  end

  context do
    
  end
end

def array2cons(array)
  cons = SNil
  array.reverse.each do |val|
    cons = SCons.new(val, cons)
  end
  cons
end

describe Env do
  before do
    @env = Env.new
  end

  context do
    it { 
      bind1 = VarBind.new(array2cons([:a]), [10])
      new_env = @env.extend_env(bind1)
      bind2 = VarBind.new(array2cons([:b]), [20])
      new_env = new_env.extend_env(bind2)
      new_env[:a].should eq 10
      new_env[:b].should eq 20
      @env[:a].should eq nil
      @env[:b].should eq nil
    }
  end
end
