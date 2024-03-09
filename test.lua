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

graph.capture("g")
a()
graph.emit("g", "graph.dot")
