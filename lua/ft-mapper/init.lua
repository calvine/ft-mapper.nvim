---Returns true is a string is nil or an empty string
---@param s string
---@return boolean
local function string_is_null_or_empty(s)
	return s == "" or s == nil
end

-- FIXME: Does clear need to be false here? Presumably yes because we do not want the commands overridden?
local ftgroup = vim.api.nvim_create_augroup("ftgroup", { clear = true })

local registered_fth = {}

local M = {}

---This is a setup function for use in package managers to pass in a list of ftplugin.register_options to set up mapping rules.
---@param opts table
function M.setup(opts)
	-- vim.print("hit setup")
	for _, value in ipairs(opts) do
		M.register_ft_map(value)
	end
end

---This function registers autocommands to to hande setting filetype.
---The opts parameter is a table containing the following properties:
--- * name      - string:                   A unique name for the file type handler.
--- * pattern   - array<string>:            A list of file name patterns that will match the generated autocommand.
--- * file_type - string:                   A string to set the file type to. An example would be `go` to set the filetype to go. **If provided handler is ignored.**
--- * handler   - function(string)->string: A function that takes in the file name and returns a string to set the filetype to.
---
--- @class ftplugin.register_options
--- @field name string String: Does this show up?
--- @field patterns table Array<string>: This is the patterns to use for setting the file type of specific files. This is the same kind of pattern used to autocommands.
--- @field file_type? string String: This is a static file type to set if the pattern is matched.
--- @field handler? function Function(number, string) -> string: This is a function that takes a buffer id and a file name and returns the desired file type as a string
---
--- @param opts ftplugin.register_options
--- @return boolean
function M.register_ft_map(opts)
	-- vim.print("hi register ft map")
	local no_name = string_is_null_or_empty(opts.name)
	if no_name == true then
		error("attempted to register a filetype handler without a name")
	end
	if #opts.patterns == 0 then
		error("patterens array is empty or not an array")
	end
	if registered_fth[opts.name] ~= nil then
		-- Delete existing autocommand.
		vim.api.nvim_del_autocmd(registered_fth[opts.name])
	end
	if string_is_null_or_empty(opts.file_type) == false then
		registered_fth[opts.name] = vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
			pattern = opts.patterns,
			group = ftgroup,
			callback = function(args)
				vim.bo[args.buf].filetype = opts.file_type
			end,
		})
		return true
	end
	if opts.handler ~= nil then
		registered_fth[opts.name] = vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
			pattern = opts.patterns,
			group = ftgroup,
			callback = function(args)
				-- vim.print("calling handler...")
				local ft = opts.handler(args.buf, args.file)
				-- vim.print("got " .. ft)
				vim.bo[args.buf].filetype = ft
			end,
		})
		return true
	end
	error("handler and file_type are both empty")
	return false
end

---This function unregisters a file type mapping by name. If the name provided does not exist in the ft mapper it will be ignored. This function returns true if a mapping is deleted.
---@param name string
---@return boolean
function M.unregister_ft_map(name)
	local autocommand_id = registered_fth[name]
	if autocommand_id == nil then
		return false
	end
	vim.api.nvim_del_autocmd(autocommand_id)
	return true
end

return M
