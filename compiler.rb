require './sexp'
require './instruction'

include Instruction

class Compiler
  def compile(exp, next_op = Halt.new)
    if exp.atom? then
      if symbol?(exp) then
        Refer.new(exp, next_op)
      else
        Constant.new(exp, next_op)
      end
    elsif exp.list? then
      car = exp.car
      if symbol?(car) then
        symbol = car.value
        if symbol == :quote then
          Constant.new(exp.cdr.car, next_op)
        elsif symbol == :if then
          test_exp = exp.cdr.car
          then_exp = exp.cdr.cdr.car
          else_exp = exp.cdr.cdr.cdr.car
          then_op = compile(then_exp, next_op)
          else_op = compile(else_exp, next_op)
          compile(test_exp, Test.new(then_op, else_op))
        elsif symbol == :define then
          if symbol?(exp.cdr.car) then
            # (define var val)
            var = exp.cdr.car
            val = exp.cdr.cdr.car
            compile(val, Define.new(var, next_op))
          elsif exp.cdr.car.list? then
            # (define (func arg0...) body)
            var = exp.cdr.car.car
            args = exp.cdr.car.cdr
            body = exp.cdr.cdr.car
            val = SCons.new(SSymbol.new(:lambda), SCons.new(args, SCons.new(body)))
            compile(val, Define.new(var, next_op))
          else
            raise "define syntax error"
          end
        elsif symbol == :set! then
          var = exp.cdr.car
          val = exp.cdr.cdr.car
          compile(val, Assign.new(var, next_op))
        elsif symbol == :lambda then
          vars = exp.cdr.car
          body = exp.cdr.cdr.car
          Close.new(vars, compile(body, Return.new), next_op)
        elsif symbol == :'call/cc' then
          compile_call_cc(exp, next_op)
        else
          compile_func_apply(exp, next_op)
        end
      else
        compile_func_apply(exp, next_op)
      end
    end
  end

  def compile_func_apply(exp, next_op)
    fn = exp.car
    args = exp.cdr
    fn_apply_op = compile(fn, Apply.new)
    args_fn_apply_op = compile_args(args, fn_apply_op)
    # TODO tail call optimization
    Frame.new(args_fn_apply_op, next_op)
  end

  def compile_args(args, fn_apply_op)
    if (args == SNil) then
      fn_apply_op
    else
      args = reverse(args)
      args_op = compile(args.car, Argument.new(fn_apply_op))
      args = args.cdr
      until args == SNil
        args_op = compile(args.car, Argument.new(args_op))
        args = args.cdr
      end
      args_op
    end
  end

  def reverse(args)
    if args.cdr == SNil then
      return args
    end

    rev_args = SCons.new(args.car)
    args = args.cdr
    until args == SNil
      rev_args = SCons.new(args.car, rev_args)
      args = args.cdr
    end
    rev_args
  end

  def compile_call_cc(exp, next_op)
    body = exp.cdr.car
    Frame.new(Conti.new(Argument.new(compile(body, Apply.new))), next_op)
  end

  def symbol?(exp)
    exp.is_a?(SSymbol)
  end
end
