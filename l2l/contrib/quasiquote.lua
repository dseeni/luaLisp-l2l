local reader = require("l2l.reader")
local compiler = require("l2l.compiler")
local utils = require("leftry.utils")
local read = reader.read
local symbol = reader.symbol
local list = require("l2l.list")
local vector = require("l2l.vector")

local function read_quasiquote(invariant, position)
  local rest, values = read(invariant, position + 1)
  if rest then
    if not values[1] then
      error('nothing to quasiquote')
    end
    values[1] = list(symbol("quasiquote"), values[1])
    return rest, values
  end
end

local function read_quasiquote_eval(invariant, position)
  local rest, values = read(invariant, position + 1)
  if rest then
    if not values[1] then
      error('nothing to quasiquote-eval')
    end
    values[1] = list(symbol("quasiquote-eval"), values[1])
    return rest, values
  end
end

local function quasiquote_eval(invariant, car, output)
  invariant._quasiquote_eval = invariant._quasiquote_eval or function(value)
    return quasiquote_eval(invariant, value, output)
  end
  if utils.hasmetatable(car, list) then
    if car:car() == symbol("quasiquote-eval") then
      local cdr = car:cdr()
      assert(list.__len(cdr) == 1,
        "quasiquote_eval only accepts one parameter.")
      return compiler.compile(invariant, cdr:car(), compile)
    end
    return list.cast(car, invariant._quasiquote_eval)
  end
  return car
end

local function compile_quasiquote(invariant, cdr, output)
  assert(list.__len(cdr) == 1, "quasiquote only accepts one parameter.")
  return quasiquote_eval(invariant, cdr:car(), output)
end

return function(invariant)
  reader.register_R(invariant, ",", read_quasiquote_eval)
  reader.register_R(invariant, "`", read_quasiquote)
  compiler.register_L(invariant, "quasiquote", compile_quasiquote)
  -- compiler.register_L(invariant, "quasiquote-eval", compile_quasiquote_eval)
end
