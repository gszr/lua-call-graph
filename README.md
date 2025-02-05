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
# test/test.lua
```

the library outputs the following call graph:

![call graph](./test/graph.svg)
