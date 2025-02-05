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
  filename = "graph.dot",
  ignores = {"something"},
})

g:capture()
pcall(a) -- this one is found
pcall(function() end) -- this one cannot be found - so shows as unknown
g:stop()
c()
g:emit()
