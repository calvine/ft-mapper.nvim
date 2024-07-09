# FileType Mapper NVIM Plugin

This is a very simple plugin that allows you to configure autocommands to set
the file type for files matching certain patterns.

You can specify a static file type or provider a string which receives the
opened buffer id and the file name and returns a string which is what the file
type of the buffer will be set it.

## Actual example configuration with lazy nvim

> Supporting code for this example is below

```lua
local getMultiExtensionTarget = require('custom/util/handle_template_file').getMultiExtensionTarget
-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'calvine/ft-mapper.nvim',
    opts = {
      {
        name = 'multi-extension-template-file',
        patterns = { '*.*.tpl', '*.*.tftpl' },
        handler = function(bufId, filename)
          local target_type = getMultiExtensionTarget(filename, 1)
          return target_type
        end,
      },
      {
        name = 'terraform',
        patterns = { '*.tf' },
        file_type = 'terraform',
      },
    },
  },
}
```

### Supporting code for context on the actual example

```lua
---This function splits a string based on a provided delimiter. If `use_plain_search` is false (or not provided) then the delimiter will leverage pattern matching rather than a plain string search.
---Returns an array of strings.
---@param s string
---@param delimiter string
---@param use_plain_search boolean
---@return table
local function split_string(s, delimiter, use_plain_search)
  local results = {}
  local startidx = 1
  local from, to = string.find(s, delimiter, startidx, (use_plain_search or false))
  while from do
    local substring = string.sub(s, startidx, from - 1)
    table.insert(results, substring)
    startidx = to + 1
    from, to = string.find(s, delimiter, startidx, (use_plain_search or false))
  end
  local substring = string.sub(s, startidx)
  table.insert(results, substring)
  return results
end

---This function takes a file name with muliple extesions i.e: `file.json.tpl`
---And will return the extension in the file name `offset` away from the end.
---For example calling with the file name `file.json.tpl` and an offset of `1` will return `json`
---@param fileName string
---@param offset number
---@return string
local function getMultiExtensionTarget(fileName, offset)
  local parts = stringUtils.split_string(fileName, '/')
  local lastPathPart = parts[#parts]
  local filename_parts = stringUtils.split_string(lastPathPart, '.', true)
  if #filename_parts > 2 then
    -- print(second_to_last_ext)
    return filename_parts[#filename_parts - (offset or 0)]
  end
  error 'file name does not have multiple extensions'
end
return {
  getMultiExtensionTarget = getMultiExtensionTarget,
}
```
