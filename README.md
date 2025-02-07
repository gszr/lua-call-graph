# Lua Call Graph

Generate a call graph of Lua programs.

## API

### new

Create new capture instance.

**syntax**: graph.new(cfg)

Supported configs:
* `name`: call graph name
* `filename`: name for the call graph `.dot` file (defaults to `name`)
* `ignores`: an array of function names to redact from the `.dot` file
* `separator`: the character to use as separator for spaces[^1]
* `mappings`: a translation map of function names; if a function mamed `key` is
  found, it's renamed with `value`

[^1]: Some internal function names might contain spaces. For example, `for iterator`.
The `separator` value will be used to replace these spaces.

### :capture

**syntax**: *graph:capture()*

Starts capturing the call graph from that point in the program.

### :stop

**syntax**: graph:stop()

Stops capturing the call graph. A subsequent call to `:emit` generates the
call graph.

### :emit

**syntax**: *graph:emit()*

Emits the captured call graph named `name` into the DOT file `filename`.

## Example

Given the Lua code below
```lua
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
```

the library outputs the following call graph:

![call graph](./test/graph.svg)
