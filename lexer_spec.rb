require './lexer'
require 'stringio'

require 'pry'

def tokenize(s)
  lexer = Lexer.new(StringIO.new(s))
  tokens = []
  token = lexer.get_token
  while token
    tokens << token
    token = lexer.get_token
  end
  tokens
end

describe Lexer do
  context do
    it {
      tokens = tokenize("")
      tokens.size.should eq 0
    }
  end

  context do
    it {
      tokens = tokenize("123")
      token = tokens[0]
      token.type.should eq :number
      token.value.should eq 123
    }

    it {
      tokens = tokenize("a")
      token = tokens[0]
      token.type.should eq :symbol
      token.value.should eq :a
    }

    it {
      tokens = tokenize('"abc"')
      token = tokens[0]
      token.type.should eq :string
      token.value.should eq "abc"
    }
  end
  
  context do
    it {
      tokens = tokenize('abc 123 "def"')
      tokens.size.should == 3
      tokens[0].type.should eq :symbol
      tokens[0].value.should eq :abc
      tokens[1].type.should eq :number
      tokens[1].value.should eq 123
      tokens[2].type.should eq :string
      tokens[2].value.should eq "def"
    }
  end

end
