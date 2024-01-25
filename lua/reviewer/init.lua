local reviewer = {}

-- Function to get the current visual selection
function reviewer.get_visual_selection()
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

return reviewer
