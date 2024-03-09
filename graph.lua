local graph = {}
local captures = {}

function graph.capture(name)
  debug.sethook(function()
    local callee_name = debug.getinfo(2).name or ""
    local caller_name = (debug.getinfo(3) or {} ).name or "main"
    local capture = captures[name] or {}
    captures[name] = capture

    caller_name = caller_name:gsub("_", ""):gsub("-", ""):gsub("%(", ""):gsub("%)", "")
    callee_name = callee_name:gsub("_", ""):gsub("-", ""):gsub("%(", ""):gsub("%)", "")

    local entry_name = caller_name
    capture[entry_name] = capture[entry_name] or {}
    capture[entry_name][#(capture[entry_name])+1] = callee_name

    capture[#(capture) + 1] = caller_name
  end, "c")

end

local function t2s(t)
  local s = ""
  if #t > 0 then
    s = s .. "{ "
    for i, v in ipairs(t) do
      if i < #t then
        s = s .. tostring(v) .. ", "
      else
        s = s .. tostring(v) .. " "
      end
    end
    s = s .. "}"
  else
    return "{}"
  end
  return s
end

function graph.emit(name, filename)
        debug.sethook()
        local graph = captures[name]

        local f = assert(io.open(filename, "w+"))
        f:write(string.format("digraph calls {\n"))

        print(require"inspect"(graph))
        local done = {}
        for i, caller in ipairs(graph) do
            if not done[caller] then
                local callees = t2s(graph[caller])
                f:write(string.format("\t{%s} -> %s;\n", caller, callees))
                done[caller] = true
            end
        end

        f:write(string.format("\n}"))
        f:close()
end


return graph
