local reviewer = {}

-- Function to get the current visual selection
function reviewer.get_visual_selection()
	-- Get the start and end position of the visual selection
	local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))

	-- Adjust the column indices for correct substring extraction
	start_col = start_col - 1
	end_col = end_col + 1

	-- Retrieve the text from the buffer
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if #lines == 0 then
		return ""
	end
	if #lines == 1 then
		return string.sub(lines[1], start_col, end_col)
	end

	-- Extract text from the start and end lines
	lines[1] = string.sub(lines[1], start_col)
	lines[#lines] = string.sub(lines[#lines], 1, end_col)

	return table.concat(lines, "\n")
end

return reviewer
