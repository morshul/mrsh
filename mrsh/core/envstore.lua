---A store that retrieves resources from the environment.
---
---@class envstore : store*
---@field package __prefix string
local EnvironmentStore = {}

---Retrieves an environment variable from the store.
---
---@param self envstore The store itself.
---@param name string The name of the environment variable.
---
---@return string? value The value of the environment variable.
EnvironmentStore.get = function(self, name)
  return os.getenv(self.__prefix .. name)
end

---Get a collection of all available resources.
---
---@param self envstore The store itself.
---
---@return string[] resources The available resources.
EnvironmentStore.get_available_resources = function(self)
  local result = {}

  local printenv = (function()
    local process = assert(io.popen('printenv', 'r'), 'Failed to execute the printenv command.')
    local res = process:read('*a')

    process:close()
    return res --[[@as string]]
  end)()

  for line in printenv:gmatch('([^\n]*)\n?') do
    local key = line:match('^(.-)=.*$') --[[@as string]]

    if key:sub(1, #self.__prefix) == self.__prefix then
      table.insert(result, key:sub(#self.__prefix + 1))
    end
  end

  return result
end

---Get the length of the store.
---
---@param self store* The store itself.
---
---@return integer length The length of the store.
EnvironmentStore.length = function(self)
  return #self:get_available_resources()
end

---The options to use when creating the store.
---
---@class envstoreoptions
---@field prefix string The prefix to use for environment variables.

---Initializes a new instance of the environment store.
---
---@param args? envstoreoptions The options to use when creating the store.
---
---@return envstore store The environment store.
return function(args)
  args = args or {}

  local result = {}
  local behaviour = {}

  for key, value in pairs(EnvironmentStore) do
    if type(value) == 'function' then
      result[key] = value
    end
  end

  result.__prefix = args.prefix or ''

  return setmetatable(result, behaviour)
end
