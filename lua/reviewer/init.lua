local D = {}

-- Function to get the current visual selection
function D.get_visual_selection()
	-- Get the start and end position of the visual selection
	local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))

	-- Adjust for zero-indexing in nvim_buf_get_lines API
	start_col = start_col - 1
	end_col = end_col -- No -1 here because selection is inclusive

	-- Retrieve the text from the buffer
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if #lines == 0 then
		return ""
	end

	-- Handle single-line selection
	if #lines == 1 then
		return string.sub(lines[1], start_col + 1, end_col)
	end

	-- Handle multi-line selection
	-- Adjust the first line
	lines[1] = string.sub(lines[1], start_col + 1)

	-- Adjust the last line, if it's the same as the first line, it's already adjusted
	if #lines > 1 then
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return table.concat(lines, "\n")
end

function D.send_code_to_api(code)
	local escaped_code = D.escape_string_for_json(code)
	local payload = {
		messages = {
			{ role = "system", content = "Review my code as an expert senior developer" },
			{ role = "user", content = escaped_code },
		},
		temperature = 0.7,
		max_tokens = -1,
		stream = false,
	}

	-- Convert the Lua table to JSON
	local json_payload = vim.fn.json_encode(payload)

	local cmd = "curl -X POST -H 'Content-Type: application/json' -d '"
		.. json_payload
		.. "' http://localhost:1234/v1/chat/completions"
	local handle = io.popen(cmd, "r")
	local response = handle:read("*a")
	handle:close()

	return response
end

function D.escape_string_for_json(str)
	local escapes = {
		["\\"] = "\\\\",
		['"'] = '\\"',
		["\b"] = "\\b",
		["\f"] = "\\f",
		["\n"] = "\\n",
		["\r"] = "\\r",
		["\t"] = "\\t",
	}
	return str:gsub('[\\"%b\\n\\r\\t]', escapes)
end

function D.main_function()
	local code = D.get_visual_selection()
	local response = D.send_code_to_api(code)
	D.display_response(response)
end

return D
