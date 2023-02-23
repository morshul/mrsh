---A store is a collection of resources that can be retrieved from a variety of sources.
---
---@class store*
local Store = {}

---Retrieves an object from the store.
---
---@generic T
---@param self store* The store itself.
---@param name string The name of the object.
---@param type? `T` The type of the object.
---
---@return T? value The value of the environment variable.
Store.get = function(self, name, type)
  return nil
end

---Get a collection of all available resources.
---
---@param self store* The store itself.
---
---@return string[] resources The available resources.
Store.get_available_resources = function(self)
  return {}
end

---Get the length of the store.
---
---@param self store* The store itself.
---
---@return integer length The length of the store.
Store.length = function(self)
  return 0
end
