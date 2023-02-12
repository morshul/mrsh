---Write formatted data to a stream.
---
---@param stream file* The stream to write to.
---@param format string The format string.
---@param ... any The arguments to format.
---
---@return boolean success Whether the operation was successful.
return function(stream, format, ...)
  assert(stream, 'stream is nil')
  assert(format, 'format is nil')

  local success, result = pcall(stream.write, stream, string.format(format, ...))

  if not success then
    error(result, 2)
  end

  return success
end
