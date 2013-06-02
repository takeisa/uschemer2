require './parser'
require 'stringio'

def parse(program)
  Parser.new(Lexer.new(StringIO.new(program))).parse
end

describe Parser do
  context do 
    it { parse("a").should eq :a }
  end

  context do
    it { parse("123").should eq 123 }
  end

  context do
    it { parse("( )").should eq SNil }
  end

  context do
    it { 
      exp = parse("(a 123)")
      exp.car.should eq :a
      exp.cdr.car.should eq 123
    }
  end

  context do
    it { 
      exp = parse("(a . 123)")
      exp.car.should eq :a
      exp.cdr.should eq 123
    }
  end

  context do
    it { 
      exp = parse('(a b . (123 "abc"))')
      exp.car.should eq :a
      exp.cdr.car.should eq :b
      exp.cdr.cdr.car.should eq 123
      exp.cdr.cdr.cdr.car.should eq "abc"
    }
  end

end
