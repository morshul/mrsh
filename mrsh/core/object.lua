local extensions = require('mrsh.core.object.extensions')

---The ultimate base class for all objects.
---
---@class object
---@field package __events { [string]: { strong: fun(self: object, ...: any)[], weak: fun(self: object, ...: any)[] } }
---@field package __instance { class: table, properties: boolean, auto_events: boolean }
local Object = {}

---Adds the `listener` function to the end of the listeners array for the event named `event_name`.
---
---@param self object The object itself.
---@param event_name string The name of the event.
---@param listener fun(self: object, ...: any) The callback function.
---
---@return object self The object itself, for chaining.
Object.on = function(self, event_name, listener)
  assert(type(event_name) == 'string', 'Expected `event_name` to be a string (got %s)', type(event_name))
  assert(type(listener) == 'function', 'Expected `listener` to be a function (got %s)', type(listener))

  local event = extensions.find_event(self, event_name)

  table.insert(event.strong, listener)
  self:emit('new_listener', event_name, listener)

  return self
end

---Adds a **one-time** `listener` function for the event named `event_name`.
---The next time `event_name` is triggered, this listener is removed and then invoked.
---
---@param self object The object itself.
---@param event_name string The name of the event.
---@param listener fun(self: object, ...: any) The callback function.
---
---@return object self The object itself, for chaining.
Object.once = function(self, event_name, listener)
  assert(type(event_name) == 'string', 'Expected `event_name` to be a string (got %s)', type(event_name))
  assert(type(listener) == 'function', 'Expected `listener` to be a function (got %s)', type(listener))

  local event = extensions.find_event(self, event_name)

  table.insert(event.strong, listener)
  self:emit('new_listener', event_name, listener)

  return self
end

---Syncronously calls each of the listeners registered for the event named `event_name`,
---in the order they were registered, passing the supplied arguments to each.
---
---@param self object The object itself.
---@param event_name string The name of the event.
---@param ... any The arguments to pass to the listeners.
---
---@return boolean success Whether or not the event had listeners.
Object.emit = function(self, event_name, ...)
  assert(type(event_name) == 'string', 'Expected `event_name` to be a string (got %s)', type(event_name))

  local event = extensions.find_event(self, event_name)

  for _, listener in ipairs(event.strong) do
    listener(self, ...)
  end

  for _, listener in ipairs(event.weak) do
    listener(self, ...)
    self:off(event_name, listener)
  end

  return #event.strong > 0 or #event.weak > 0
end

---Removes the specified `listener` from the listener array for the event named `event_name`.
---
---@param self object The object itself.
---@param event_name string The name of the event.
---@param listener fun(self: object, ...: any) The callback function.
---
---@return object self The object itself, for chaining.
Object.off = function(self, event_name, listener)
  assert(type(event_name) == 'string', 'Expected `event_name` to be a string (got %s)', type(event_name))
  assert(type(listener) == 'function', 'Expected `listener` to be a function (got %s)', type(listener))

  local event = extensions.find_event(self, event_name)

  for key, value in ipairs(event.strong) do
    if value == listener then
      table.remove(event.strong, key)
      self:emit('remove_listener', event_name, listener)
      break
    end
  end

  for key, value in ipairs(event.weak) do
    if value == listener then
      table.remove(event.weak, key)
      self:emit('remove_listener', event_name, listener)
      break
    end
  end

  return self
end

---Returns an array listing the events for which the emitter has registered listeners.
---
---@param self object The object itself.
---
---@return string[] events The names of all events.
Object.event_names = function(self)
  local result = {}

  for key, _ in pairs(self.__events) do
    table.insert(result, key)
  end

  return result
end

---Returns the number of listeners listening to the event named `event_name`.
---
---@param self object The object itself.
---@param event_name string The name of the event.
---
---@return fun(self: object, ...: any)[] listeners The listeners for the event.
Object.listeners = function(self, event_name)
  local event = extensions.find_event(self, event_name)

  local result = {}

  for _, listener in ipairs(event.strong) do
    table.insert(result, listener)
  end

  for _, listener in ipairs(event.weak) do
    table.insert(result, listener)
  end

  return result
end

---The options to use when creating an object.
---
---@class objectoptions
---@field class table The class to use for the object. Defaults to `nil`.
---@field properties boolean Automatically call getters and setters for properties. Defaults to `false`.
---@field auto_events boolean Automatically generate `property::x` events when an unknown property is set. Defaults to `false`.

---The ultimate base class for all objects.
---
---@param args? objectoptions The options to use when creating the object.
---
---@return object object The new object.
return function(args)
  args = args or {}

  local result = {}
  local behaviour = {}

  for key, value in pairs(Object) do
    if type(value) == 'function' then
      result[key] = value
    end
  end

  result.__events = {}
  result.__instance = {}

  result.__instance.class = args.class or {}
  result.__instance.auto_events = args.auto_events or false

  if args.auto_events then
    result.__instance.class = result.__instance.class and setmetatable({}, {
      __index = args.class,
    }) or {}
  end

  if args.properties then
    behaviour.__index = extensions.get_missing
    behaviour.__newindex = extensions.set_missing
  elseif args.class then
    behaviour.__index = args.class
  end

  return setmetatable(result, behaviour)
end
