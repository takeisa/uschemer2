require './lexer'
require './sexp'

class Parser
  def initialize(lexer)
    @lexer = lexer
  end

  def parse
    parse_sexp
  end

  def parse_sexp
    parse_list || parse_atom
  end

  def parse_list
    token = @lexer.get_token
    unless token.type == :'('
      @lexer.unget_token(token)
      return nil
    end

    cons = SNil
    list = cons

    while TRUE
      token = @lexer.get_token
      if token.type == :')' then
        break
      elsif token.type == :'.' then
        cons.cdr = parse_sexp
        token_rpar = @lexer.get_token
        raise "More than one object follows . in list" unless token_rpar.type == :')'
        break
      end
      @lexer.unget_token(token)
      if cons == SNil then
        cons = SCons.new
        list = cons
      else
        cons.cdr = SCons.new
        cons = cons.cdr
      end
      cons.car = parse_sexp
    end

    list
  end

  def parse_atom
    token = @lexer.get_token
    token.value
  end
end

