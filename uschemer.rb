require 'optparse'
require 'pp'
require './parser'
require './lexer'
require './compiler'
require './vm'
require './sexp'
require 'pry'

def main
  options = {}
  
  option_parser = OptionParser.new do |opt|
    executable_name = File.basename($PROGRAM_NAME)
    opt.banner = "Micro Scheme on Ruby\n\n" +
      "Usage: #{executable_name} [options] [file]\n\n"
  end

  option_parser.parse!
#  puts options.inspect

  if ARGV.size == 0 then
    repl
  end
end

def sym(symbol)
  SSymbol.new(symbol)
end

def repl
  lexer = Lexer.new(STDIN)
  parser = Parser.new(lexer)
  compiler = Compiler.new
  vm = VM.new
  init_env(vm.e)

  print "Micro Schme"

  while true
    print "> "

    exp = parser.parse
#    puts "exp=#{exp.inspect}\n"

    operator = compiler.compile(exp)
#    puts "operator=#{operator.inspect}\n"

    obj = vm.eval(operator)
    print "#{obj.to_s}\n"
  end
end

def init_env(env)
  env[sym(:+)] = lambda {|*x| x.reduce {|a, b| a + b}}
  env[sym(:-)] = lambda {|*x| if x.size == 1 then -x[0] else x.reduce {|a, b| a - b} end}
  env[sym(:*)] = lambda {|*x| x.reduce(1) {|a, b| a * b}}
  env[sym(:'/')] = lambda {|*x| x.reduce(1) {|a, b| a / b}}
end

main
