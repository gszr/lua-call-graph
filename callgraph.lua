local graph = {}
graph.__index = graph


local DEFAULT_IGNORES = {
  "stop"
}
local UNNAMED_FUNC_NAME = "_unnamed"


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
    local callee_debug = debug.getinfo(2)
    local caller_debug = debug.getinfo(3) or {}
    local callee_name = callee_debug.name or ""
    local caller_name = caller_debug.name or "main"

    if self.cfg.ignores[callee_name] or self.cfg.ignores[caller_name] then
      return
    end

    local capture = self.captures[self.cfg.name] or {}
    self.captures[self.cfg.name] = capture

    if callee_name == "" then
      for env_key, env_val in pairs(_G) do
        if env_val == callee_debug.func then
          callee_name = env_key
          break
        end
      end
      callee_name = callee_name == "" and UNNAMED_FUNC_NAME or callee_name
    end

    caller_name = caller_name:gsub("-", ""):gsub("%(", ""):gsub("%)", ""):gsub(" ", self.cfg.separator)
    callee_name = callee_name:gsub("-", ""):gsub("%(", ""):gsub("%)", ""):gsub(" ", self.cfg.separator)

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
  assert(cfg.name, "name: capture name is required")
  assert(cfg.ignores and type(cfg.ignores) == "table" and #cfg.ignores ~= 0,
    "ignores: must be an array")

  cfg.filename = cfg.filename or cfg.name
  cfg.ignores = cfg.ignores or {}

  local ignores = {table.unpack(DEFAULT_IGNORES)}
  for _, v in ipairs(cfg.ignores or {}) do
    ignores[#ignores+1] = v
  end
  for _, v in ipairs(ignores) do
    ignores[v] = true
  end

  cfg.separator = cfg.separator or "_"

  return setmetatable({
    cfg = cfg,
    captures = {},
  }, graph)
end


return graph
