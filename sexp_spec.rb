require './sexp'

describe SCons do
  context do
    it { SCons.new("1").length.should eq 1 }
  end

  context do
    it { SCons.new("1", SCons.new("2")).length.should eq 2 }
  end
end
