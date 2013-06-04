def ssymbol(rb_symbol)
  SSymbol.new(rb_symbol)
end

def sstring(rb_string)
  SString.new(rb_string)
end

def snumber(rb_number)
  SNumber.new(rb_number)
end

def class_value(obj)
  [obj.class, obj.value]
end

