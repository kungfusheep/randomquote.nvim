local cache_file = vim.fn.stdpath("data") .. "/random_quote_cache.json"

local function read_cache()
	local file = io.open(cache_file, "r")
	if file then
		local content = file:read("*all")
		file:close()
		return vim.fn.json_decode(content)
	end
	return nil
end

local function write_cache(data)
	local file = io.open(cache_file, "w")
	if file then
		file:write(vim.fn.json_encode(data))
		file:close()
	end
end

local function fetch_random_quote(callback)
	local url = "https://api.quotable.io/quote/random?tags=inspirational"
	local command = { "curl", "-s", url }
	local output = ""

	vim.fn.jobstart(command, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			output = output .. table.concat(data, "\n")
		end,
		on_exit = function()
			local response = vim.fn.json_decode(output)
			write_cache({ content = response.content, author = response.author })
			callback(response.content, response.author)
		end,
	})
end

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

local function display_quote(quote, author)
	local width_percent = 0.6
	local width = math.floor(vim.api.nvim_win_get_width(0) * width_percent)

	quote = quote or ""
	author = author or "Unknown"

	local quote_lines = wrap_text(quote, width)
	local author_line = "-- " .. author

	local start_row = math.floor((vim.api.nvim_win_get_height(0) - #quote_lines - 1) / 2)
	local start_col = math.floor((vim.api.nvim_win_get_width(0) - width) / 2)

	-- Create a new buffer for the quote
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)

	-- Switch to the quote buffer
	vim.api.nvim_set_current_buf(buf)

	-- Set the buffer to be modifiable
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)

	for i, line in ipairs(quote_lines) do
		local row = start_row + i - 1
		vim.api.nvim_buf_set_lines(buf, row, row, false, { string.rep(" ", start_col) .. line })
	end

	local author_row = start_row + #quote_lines
	local author_col = math.floor((vim.api.nvim_win_get_width(0) - #author_line) / 2)
	vim.api.nvim_buf_set_lines(buf, author_row, author_row, false, { string.rep(" ", author_col) .. author_line })

	-- Set the buffer to be immutable
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	-- Hide UI elements
	vim.opt.laststatus = 0
	vim.opt.ruler = false
	vim.opt.showmode = false
	vim.opt.showcmd = false
end

local function display_random_quote()
	local cached_data = read_cache()
	if cached_data then
		display_quote(cached_data.content, cached_data.author)
	end

	fetch_random_quote(function(quote, author)
		if not cached_data then
			display_quote(quote, author)
		end
	end)
end


local function setup()
	display_random_quote()
end


return {
	display_random_quote = display_random_quote,
	setup = setup,
}
