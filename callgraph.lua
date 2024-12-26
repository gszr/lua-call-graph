local graph = {}
graph.__index = graph


local ignores = {
  ["stop"] = true,
}

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


function graph:capture()
  debug.sethook(function()
    local callee_name = debug.getinfo(2).name or ""
    local caller_name = (debug.getinfo(3) or {} ).name or "main"

    if ignores[callee_name] or ignores[caller_name] then
      return
    end

    local capture = self.captures[self.cfg.name] or {}
    self.captures[self.cfg.name] = capture

    caller_name = caller_name:gsub("_", ""):gsub("-", ""):gsub("%(", ""):gsub("%)", "")
    callee_name = callee_name:gsub("_", ""):gsub("-", ""):gsub("%(", ""):gsub("%)", "")

    local entry_name = caller_name
    capture[entry_name] = capture[entry_name] or {}
    capture[entry_name][#(capture[entry_name])+1] = callee_name

    capture[#(capture) + 1] = caller_name
  end, "c")

end


function graph:stop()
  debug.sethook()
end


function graph:emit()
  local g = self.captures[self.cfg.name]

  local f = assert(io.open(self.cfg.filename, "w+"))
  f:write(string.format("digraph %s {\n", self.cfg.name))

  local done = {}
  for _, caller in ipairs(g) do
    if not done[caller] then
      local callees = t2s(g[caller])
      f:write(string.format("\t{%s} -> %s;\n", caller, callees))
      done[caller] = true
    end
  end

  f:write(string.format("}"))
  f:close()
end


function graph.new(cfg)
  -- cfg.name
  -- cfg.filename

  assert(cfg.name, "name: capture name is required")
  cfg.filename = cfg.filename or cfg.name

  return setmetatable({
    cfg = cfg,
    captures = {},
  }, graph)
end


return graph
