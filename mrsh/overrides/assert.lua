---Raises an error if the value of its argument `value` is false (i.e., `nil` or `false`).
---Otherwise, returns all its arguments.
---
---@generic T
---
---@param value? T The value to assert.
---@param message? string The error message to throw.
---@param ... any The arguments to format into the error message.
---
---@return T self The value that was asserted.
return function(value, message, ...)
  local fprintf = require('mrsh.overrides.fprintf')

  message = message or 'assertion failed!\n'

  if not value then
    local info = debug.getinfo(2, 'Sl')
    local stacktrace = debug.traceback('', 2)
    stacktrace = stacktrace:sub(stacktrace:find('\n', 1, true) + 1)

    fprintf(
      io.stderr,
      'mrsh: %s:%d: %s\n%s\n',
      info.short_src,
      info.currentline,
      string.format(message, ...),
      stacktrace
    )
    os.exit(1)
  end

  return value
end
