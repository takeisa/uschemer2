require './sexp'
require './rspec_utils'

describe SNumber do
  before do
    @num = SNumber.new(123)
  end

  context do
    it { @num.should be_atom }
  end

  context do
    it { @num.should_not be_list }
  end

  context do
    it { @num.to_s.should eq 123 }
  end
end

describe SString do
  before do
    @str = SString.new("abc")
  end

  context do
    it { @str.should be_atom }
  end

  context do
    it { @str.should_not be_list }
  end

  context do
    it { @str.to_s.should eq "\"abc\"" }
  end
end

describe SSymbol do
  before do
    @sym = SSymbol.new(:abc)
  end

  context do
    it { @sym.should be_atom }
  end

  context do
    it { @sym.should_not be_list }
  end

  context do
    it { @sym.to_s.should eq "abc" }
  end
end

describe SNil do
  context do
    it { SNil.should be_list }
  end

  context do
    it { SNil.should be_atom }
  end

  context do
    it { SNil.to_s.should eq "nil" }
  end
end

describe SCons do
  before do
    @cons = SCons.new(snumber(123), sstring("abc"))
  end

  context do
    it { @cons.should_not be_atom }
  end

  context do
    it { @cons.should be_list }
  end

  context do
    it { SCons.new(sstring("1")).length.should eq 1 }
  end

  context do
    it { SCons.new(sstring("1"), SCons.new(sstring("2"))).length.should eq 2 }
  end

  context do
    it { SCons.new(sstring("abc"), snumber(123)).to_s.should eq '("abc" . 123)' }
  end

  context do
    it { SCons.new(sstring("abc"), SCons.new(snumber(123))).to_s.should eq '("abc" 123)' }
  end

  context do
    it { SCons.new(sstring("abc"), SCons.new(snumber(123), SCons.new(ssymbol(:abc)))).to_s.should eq '("abc" 123 abc)' }
  end

  context do
    it { SCons.new(sstring("abc"), SCons.new(snumber(123), ssymbol(:abc))).to_s.should eq '("abc" 123 . abc)' }
  end

  context do
    it { SCons.new(SCons.new(sstring("abc"), SCons.new(sstring("def"))), 
                   SCons.new(snumber(123), ssymbol(:abc))).to_s.should eq '(("abc" "def") 123 . abc)' }
  end
end
