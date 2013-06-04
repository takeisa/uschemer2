require 'stringio'
require './compiler'
require './parser'
require './instruction'
require './vm'
require './rspec_utils'

include Instruction

def parse(program)
  Parser.new(Lexer.new(StringIO.new(program))).parse
end

def compile(program)
  exp = parse(program)
  compiler = Compiler.new
  op = compiler.compile(exp, Halt.new)
#  print "\n#{program} -> #{op} ...\n"
  op
end

def get_next_op(operator)
  next_op = nil
  operator.instance_eval do
    next_op = @x
  end
  return next_op
end

describe Compiler do
  before do
    @vm = VM.new
    @vm.e[SSymbol.new(:true)] = true
    @vm.e[SSymbol.new(:false)] = false
    @vm.e[SSymbol.new(:+)] = lambda {|*x| x.reduce {|a, b| a + b}}
  end

  context do
    it { 
      op = compile("1")
      op.class.should eq Constant
      op2 = get_next_op(op)
      op2.class.should eq Halt
      class_value(@vm.eval(op)).should eq [SNumber, 1]
    }
  end

   context do
     it {
       @vm.e[SSymbol.new(:a)] = SNumber.new(123)
       op = compile("a")
       op.class.should eq Refer
       class_value(@vm.eval(op)).should eq [SNumber, 123]
     }
   end

  context do
    it {
      op = compile('(quote (abc "def" 123))')
      op.class.should be Constant
      res = @vm.eval(op)
      class_value(res.car).should eq [SSymbol, :abc]
      class_value(res.cdr.car).should eq [SString, "def"]
      class_value(res.cdr.cdr.car).should eq [SNumber, 123]
    }
  end

  context do
    it {
      op = compile('(if true "true" "false")')
      res = @vm.eval(op)
      class_value(res).should eq [SString, "true"]
    }
  end

  context do
    it {
      op = compile('(+ 1 2 3)')
      res = @vm.eval(op)
      class_value(res).should eq [SNumber, 6]
    }
  end

  context do
    it {
      op = compile('(+ (+ 1 2) (+ 3 4 5))')
      res = @vm.eval(op)
      class_value(res).should eq [SNumber, 15]
    }
  end

  context do
    it {
      op = compile('((lambda (a b) (+ a b)) 1 2)')
      res = @vm.eval(op)
      class_value(res).should eq [SNumber, 3]
    }
  end

  context do
    it {
      @vm.e[SSymbol.new(:a)] = SNumber.new(1)
      op = compile('(set! a 2)')
      res = @vm.eval(op)
      class_value(@vm.e[SSymbol.new(:a)]).should eq [SNumber, 2]
    }
  end

  context do
    it {
      op = compile('
(((lambda (a)
    (lambda (b) (+ a b))) 10) 20)
')
      res = @vm.eval(op)
      class_value(res).should eq [SNumber, 30]
    }
  end

  context do
    it {
      op = compile('(+ 1 (call/cc (lambda (k) 2)))')
      res = @vm.eval(op)
      class_value(res).should eq [SNumber, 3]
    }
  end

  context do
    it {
      op = compile('(+ 1 (call/cc (lambda (k) (k 3))))')
      res = @vm.eval(op)
      class_value(res).should eq [SNumber, 4]
    }
  end
end
