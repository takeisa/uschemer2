require 'optparse'
require 'pry'
require './scheme'

def main
  options = {}
  
  option_parser = OptionParser.new do |opt|
    executable_name = File.basename($PROGRAM_NAME)
    opt.banner = "Micro Scheme on Ruby\n\n" +
      "Usage: #{executable_name} [options] [file]\n\n"
  end

  option_parser.parse!
#  puts options.inspect

  scheme = Scheme.new

  if ARGV.size == 0 then
    scheme.repl
  end
end

def sym(symbol)
  SSymbol.new(symbol)
end

main
