require 'stringio'
require './compiler'
require './parser'
require './instruction'
require './vm'

include Instruction

def parse(program)
  Parser.new(Lexer.new(StringIO.new(program))).parse
end

def compile(program)
  exp = parse(program)
  compiler = Compiler.new
  op = compiler.compile(exp, Halt.new)
  print "\n#{program} -> #{op} ...\n"
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
    @vm.e[:true] = true
    @vm.e[:false] = false
    @vm.e[:+] = lambda {|*x| x.reduce {|a, b| a + b}}
  end

  context do
    it { 
      op = compile("1")
      op.is_a?(Constant).should be_true
      op2 = get_next_op(op)
      op2.is_a?(Halt).should be_true
      @vm.eval(op).should eq 1
    }
  end

  context do
    it {
      @vm.e[:a] = 123
      op = compile("a")
      op.is_a?(Refer).should be_true
      @vm.eval(op).should eq 123
    }
  end

  context do
    it {
      op = compile('(quote (abc "def" 123))')
      op.is_a?(Constant).should be_true
      res = @vm.eval(op)
      res.car.should eq :abc
      res.cdr.car.should eq "def"
      res.cdr.cdr.car.should eq 123
    }
  end

  context do
    it {
      op = compile('(if true "true" "false")')
      res = @vm.eval(op)
      res.should eq "true"
    }
  end

  context do
    it {
      op = compile('(+ 1 2 3)')
      res = @vm.eval(op)
      res.should eq 6
    }
  end

  context do
    it {
      op = compile('(+ (+ 1 2) (+ 3 4 5))')
      res = @vm.eval(op)
      res.should eq 15
    }
  end

  context do
    it {
      op = compile('((lambda (a b) (+ a b)) 1 2)')
      res = @vm.eval(op)
      res.should eq 3
    }
  end

  context do
    it {
      @vm.e[:a] = 1
      op = compile('(set! a 2)')
      res = @vm.eval(op)
      @vm.e[:a].should eq 2
    }
  end

  context do
    it {
      op = compile('
(((lambda (a)
    (lambda (b) (+ a b))) 10) 20)
')
      res = @vm.eval(op)
      res.should eq 30
    }
  end

  context do
    it {
      op = compile('(+ 1 (call/cc (lambda (k) 2)))')
      res = @vm.eval(op)
      res.should eq 3
    }
  end

  context do
    it {
      op = compile('(+ 1 (call/cc (lambda (k) (k 3))))')
      res = @vm.eval(op)
      res.should eq 4
    }
  end
end
