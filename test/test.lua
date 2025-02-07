local callgraph = require"callgraph"

function a()
  b()
end

function b()
  c()
  print()
end

function c()
  local t = {"a", "b"}
  for _, _ in pairs(t) do end
  d()
end

function d()
  print("")
end

local g = callgraph.new({
  name = "callgraph",
  filename = "test/graph.dot",
  ignores = {"something"},
  mappings = {b = "b_is_renamed"},
})

g:capture()
pcall(a) -- this one is found
pcall(function() end) -- this one cannot be found - so shows as unknown
g:stop()
c()
g:emit()
