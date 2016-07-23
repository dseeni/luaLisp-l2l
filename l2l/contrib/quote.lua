local reader = require("l2l.reader")
local compiler = require("l2l.compiler")
local read = reader.read
local symbol = reader.symbol
local list = require("l2l.list")

local function read_quote(invariant, position)
  local rest, values = read(invariant, position + 1)
  if rest then
    values[1] = list(symbol("quote"), values[1])
    return rest, values
  end
end

local function compile_quote(invariant, cdr, output)
  assert(list.__len(cdr) == 1, "quote only accepts one parameter.")
  return cdr:car()
end

return function(invariant)
  reader.register_R(invariant, "'", read_quote)
  compiler.register_L(invariant, "quote", compile_quote)
end
