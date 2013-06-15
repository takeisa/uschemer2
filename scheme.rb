require 'pp'
require './parser'
require './lexer'
require './compiler'
require './vm'
require './sexp'

class Scheme
  def initialize
    lexer = Lexer.new(STDIN)
    @parser = Parser.new(lexer)
    @compiler = Compiler.new
    @vm = VM.new
    init_env(@vm.e)
  end

  def repl
    print "Micro Scheme\n"
    
    while true
      print "> "
      
      exp = @parser.parse
      # puts "exp=#{exp.inspect}\n"
      
      operator = @compiler.compile(exp)
      # puts "operator=#{operator.inspect}\n"
      
      obj = @vm.eval(operator)
      print "#{obj.to_s}\n"
    end
  end

  def init_env(env)
    # arithmetic
    env[sym(:+)] = lambda {|*x| x.reduce {|a, b| a + b}}
    env[sym(:-)] = lambda {|*x| if x.size == 1 then -x[0] else x.reduce {|a, b| a - b} end}
    env[sym(:*)] = lambda {|*x| x.reduce(1) {|a, b| a * b}}
    env[sym(:'/')] = lambda {|*x| x.reduce(1) {|a, b| a / b}}
    
    # list

    # env[sym(:list)] = lambda do |*x| 
    #   x.reduce(nil) do |a, x|
    #     if a.nil? then
    #       SCons.new(x)
    #     else
    #       a.cdr = SCons.new(x)
    #     end
    #   end
    # end
  end
end
