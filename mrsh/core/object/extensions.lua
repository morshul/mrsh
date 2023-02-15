---@diagnostic disable: invisible

local extensions = {}

---Checks if the given object is valid.
---
---@param object object The object to check.
---
---@return object object The object itself.
extensions.check = function(object)
  -- stylua: ignore start
  assert(type(object) == 'table', 'Expected `object` to be a table (got %s)', type(object))
  assert(type(object.__events) == 'table', 'Expected `object.__events` to be a table (got %s)', type(object.__events))
  assert(type(object.__instance) == 'table', 'Expected `object.__instance` to be a table (got %s)', type(object.__instance))

  assert(type(object.__instance.class) == 'table', 'Expected `object.__instance.class` to be a table (got %s)', type(object.__instance.class))
  assert(type(object.__instance.auto_events) == 'boolean', 'Expected `object.__instance.auto_events` to be a boolean (got %s)', type(object.__instance.auto_events))
  -- stylua: ignore end

  for name, event in pairs(object.__events) do
    assert(type(name) == 'string', 'Expected `name` to be a string (got %s)', type(name))
    assert(type(event) == 'table', 'Expected `event` to be a table (got %s)', type(event))

    assert(type(event.strong) == 'table', 'Expected `event.strong` to be a table (got %s)', type(event.strong))
    assert(type(event.weak) == 'table', 'Expected `event.weak` to be a table (got %s)', type(event.weak))

    for _, callback in ipairs(event.strong) do
      assert(type(callback) == 'function', 'Expected `callback` to be a function (got %s)', type(callback))
    end

    for _, callback in ipairs(event.weak) do
      assert(type(callback) == 'function', 'Expected `callback` to be a function (got %s)', type(callback))
    end
  end

  return object
end

---Finds the event with the given name on the given object.
---
---If the event does not exists, it will be created.
---
---@param object object The object to find the event on.
---@param event_name string The name of the event to find.
---
---@return { strong: fun(self: object, ...: any)[], weak: fun(self: object, ...: any)[] } event The event.
extensions.find_event = function(object, event_name)
  object = extensions.check(object)

  if not object.__events[event_name] then
    assert(type(event_name) == 'string', 'Expected `event_name` to be a string (got %s)', type(event_name))

    object.__events[event_name] = {
      strong = {},
      weak = setmetatable({}, {
        __mode = 'kv',
      }),
    }
  end

  return object.__events[event_name]
end

---Gets the value of the given key on the given object.
---
---@param object object The object to look up the property on.
---@param key string The name of the property.
---
---@return unknown? value The value of the property.
extensions.get_missing = function(object, key)
  local class = rawget(object.__instance, 'class')
  local lookup = 'get_' .. key

  if rawget(object, lookup) then
    return rawget(object, lookup)()
  elseif class and class[lookup] then
    return class[lookup](object)
  elseif class then
    return class[key]
  end

  return nil
end

---Sets the value of the given key on the given object.
---
---@param object object The object to set the property on.
---@param key string The name of the property.
---@param value any The value to set the property to.
extensions.set_missing = function(object, key, value)
  local class = rawget(object.__instance, 'class')
  local lookup = 'set_' .. key
  local lookup_event = 'property::' .. key

  if rawget(object, lookup) then
    return rawget(object, lookup)(object, value)
  elseif class and class[lookup] then
    return class[lookup](object, value)
  elseif rawget(object.__instance, 'auto_events') then
    local changed = class[key] ~= value
    class[key] = value

    if changed then
      object:emit(lookup_event, value)
    end
  elseif (not rawget(object, lookup)) and not (class and class['get_' .. key]) then
    return rawset(object, key, value)
  else
    fprintf(io.stderr, 'Cannot modify read-only property `%s`', key)
  end
end

return extensions
