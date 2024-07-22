-- you can configure the plugin by passing a table to the setup function
local config = {
	close_key = "q", -- default key to close the quote window
}

-- wrap_text wraps text to a given width by breaking it into lines
local function wrap_text(text, width)
	local lines = {}
	local line = ""
	for word in string.gmatch(text, "%S+") do
		if #line + #word + 1 > width then
			table.insert(lines, line)
			line = word
		else
			if #line > 0 then
				line = line .. " " .. word
			else
				line = word
			end
		end
	end
	table.insert(lines, line)
	return lines
end

-- display_quote displays a quote in a new window
local function display_quote(quote, author)
	if quote == nil then
		quote = "Failed to fetch quote. Please try again."
		author = ""
	end

	local width = vim.api.nvim_win_get_width(0)
	local height = vim.api.nvim_win_get_height(0) + 8

	local quote_lines = wrap_text(quote, math.max(math.floor(width / 3), 50))
	local author_line = "-- " .. author

	local start_row = math.floor((height - #quote_lines - 1) / 2) - 3
	local start_col = math.floor((width - #quote_lines[1]) / 2)

	-- Create a new buffer for the quote
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)

	-- Set the buffer to be modifiable
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)

	-- insert height number of empty lines
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn['repeat']({ "" }, height))

	for i, line in ipairs(quote_lines) do
		local row = start_row + i - 1
		vim.api.nvim_buf_set_lines(buf, row, row, false, { string.rep(" ", start_col) .. line })
	end

	local author_row = start_row + #quote_lines
	local author_col = math.max(start_col + #quote_lines[#quote_lines] - #author_line, start_col)
	vim.api.nvim_buf_set_lines(buf, author_row, author_row, false, { string.rep(" ", author_col) .. author_line })

	-- Set the buffer to be immutable
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	-- Create a new window for the quote buffer
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		col = 0,
		row = 0,
		style = 'minimal',
		border = 'none',
	})

	vim.api.nvim_win_set_option(win, 'number', false)
	vim.api.nvim_win_set_option(win, 'relativenumber', false)
	vim.api.nvim_win_set_option(win, "foldcolumn", '0')
	vim.api.nvim_win_set_option(win, "signcolumn", 'no')
	vim.api.nvim_win_set_option(win, "colorcolumn", '')
	-- Set the background color of the window to match the default background
	vim.api.nvim_win_set_option(win, 'winhl', 'Normal:Normal')
	-- set the font colour of the buffer to match the default comment colour
	vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:Comment')
	vim.api.nvim_win_set_option(win, 'cursorcolumn', false)

	vim.api.nvim_win_call(win, function()
		vim.cmd('set nolist')
		vim.cmd('set noruler')
	end)

	-- Create an autocommand to close the quote window when leaving it
	vim.cmd([[
    augroup CloseQuoteWindow
      autocmd!
      autocmd BufLeave <buffer> execute 'bwipeout' . bufnr('%')
    augroup END
  ]])

	-- Create a keymap to close the quote window when pressing 'q'
	vim.api.nvim_buf_set_keymap(buf, 'n', config.close_key, '<cmd>close<CR>',
		{ nowait = true, noremap = true, silent = true })
end


-- reads a random quote from the disk instead of the api.
local function pick_random_quote(callback)
	local quotes = dofile("quotes.lua")
	local random_index = math.random(1, #quotes)
	local quote = quotes[random_index].content
	local author = quotes[random_index].author
	callback(quote, author)
	quotes = nil -- Allow the data to be garbage collected
end

-- display_random_quote grabs a random quote from the API and/or cache and displays it
local function display_random_quote()
	pick_random_quote(display_quote)
end

-- display_quote("Hello, World!", "Anonymous")
-- display_random_quote()

-- setup function to be called when the plugin is loaded
local function setup(opts)
	-- Check if Vim has been asked to do something else
	if vim.fn.argc() > 0 then
		return
	end

	math.randomseed(os.time())

	config = vim.tbl_extend("force", config, opts or {})

	display_random_quote()
end

-- Create a command to display a random quote
vim.cmd([[
  command! RandomQuote lua require('randomquote').display_random_quote()
]])

-- Return the public API
return {
	display_random_quote = display_random_quote,
	setup = setup,
}
