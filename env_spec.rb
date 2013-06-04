require './env'
require './sexp'

describe VarBind do
  before do
    @bind = VarBind.new
    @bind[SSymbol.new(:a)] = "a"
    @bind[SSymbol.new(:b)] = nil
  end

  context do
    it { @bind[SSymbol.new(:a)].should eq "a" }
  end

  context do
    it { @bind[SSymbol.new(:b)].should eq nil }
  end

  context do
    it { @bind[SSymbol.new(:undefined)].should eq nil }
  end

  context do
    it { @bind.bind?(SSymbol.new(:a)).should eq true }
  end

  context do
    it { @bind.bind?(SSymbol.new(:b)).should be_true }
  end

  context do
    it { @bind.bind?(SSymbol.new(:undefined)).should be_false }
  end

  context do
    it {
      bind = VarBind.new(SCons.new(SSymbol.new(:a), SCons.new(SSymbol.new(:b))), [1, 2])
      bind[SSymbol.new(:a)].should eq 1
      bind[SSymbol.new(:b)].should eq 2
    }
  end

  context do
    
  end
end

def array2cons(array)
  cons = SNil
  array.reverse.each do |val|
    cons = SCons.new(SSymbol.new(val), cons)
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
      new_env[SSymbol.new(:a)].should eq 10
      new_env[SSymbol.new(:b)].should eq 20
      @env[SSymbol.new(:a)].should eq nil
      @env[SSymbol.new(:b)].should eq nil
    }
  end
end
