require './parser'
require './sexp'
require 'stringio'

def parse(program)
  Parser.new(Lexer.new(StringIO.new(program))).parse
end

def class_value(obj)
  [obj.class, obj.value]
end

describe Parser do
  context do 
    it { class_value(parse("a")).should eq [SSymbol, :a] }
  end

  context do
    it { class_value(parse("123")).should eq [SNumber, 123] }
  end

  context do
    it { parse("( )").should eq SNil }
  end

  context do
    it { 
      exp = parse("(a 123)")
      class_value(exp.car).should eq [SSymbol, :a]
      class_value(exp.cdr.car).should eq [SNumber, 123]
    }
  end

  context do
    it { 
      exp = parse("(a . 123)")
      class_value(exp.car).should eq [SSymbol, :a]
      class_value(exp.cdr).should eq [SNumber, 123]
    }
  end

  context do
    it { 
      exp = parse('(a b . (123 "abc"))')
      class_value(exp.car).should eq [SSymbol, :a]
      class_value(exp.cdr.car).should eq [SSymbol, :b]
      class_value(exp.cdr.cdr.cdr.car).should eq [SString, "abc"]
    }
  end

  context do
    it { lambda{ parse("(a 123") }.should raise_error(Exception, "No more tokens") }
  end

end
