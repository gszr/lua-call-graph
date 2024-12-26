local graph = require"graph"

function a()
  b()
end

function b()
  c()
  print()
end

function c()
  d()
end

function d()
  print("")
end

local g = graph.new({
  name = "callgraph",
  filename = "graph.dot",
})

g:capture()
a()
g:stop()
c()
g:emit()
