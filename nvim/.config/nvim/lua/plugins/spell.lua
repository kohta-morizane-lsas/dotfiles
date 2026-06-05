local dict_path = vim.fn.stdpath("config") .. "/spell/harper-dict.txt"

local function ensure_dict_file()
	local dir = vim.fn.fnamemodify(dict_path, ":h")
	vim.fn.mkdir(dir, "p")
	if vim.fn.filereadable(dict_path) == 0 then
		vim.fn.writefile({}, dict_path)
	end
end

ensure_dict_file()

local function restart_harper()
	for _, client in ipairs(vim.lsp.get_clients({ name = "harper_ls" })) do
		local bufs = vim.tbl_keys(client.attached_buffers)
		vim.lsp.stop_client(client.id, true)
		vim.defer_fn(function()
			for _, bufnr in ipairs(bufs) do
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr })
				end
			end
		end, 500)
	end
end

local function add_word_to_dict()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end
	local f = io.open(dict_path, "a")
	if not f then
		vim.notify("Failed to open dictionary: " .. dict_path, vim.log.levels.ERROR)
		return
	end
	f:write(word .. "\n")
	f:close()
	restart_harper()
	vim.notify("Added '" .. word .. "' to harper dictionary")
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				typos_lsp = {
					init_options = {
						diagnosticSeverity = "Warning",
					},
				},
				harper_ls = {
					settings = {
						["harper-ls"] = {
							userDictPath = dict_path,
							isolateEnglish = true,
							linters = {
								-- 邪魔になったルールをここで false にする
								UseTitleCase = false, -- "Try to use title case in headings"
								ToDoHyphen = false, -- "Hyphenate `to-do`"
								SentenceCapitalization = false, -- "This sentence does not start with a capital letter"
								UnicodeEllipsis = false, -- "Use the Unicode ellipsis character"
								AcronymCapitalization = false, -- "This word's canonical spelling is all-caps"
								OrthographicConsistency = false,
								EllipsisLength = false,
								QuoteSpacing = false,
								PhrasalVerbAsCompoundNoun = false,
								UnclosedQuotes = false,
								UseEllipsisCharacter = false,
								ExpandMinimum = false,
								ExpandTimeShorthands = false,
								CommaFixes = false,
								DisjointPrefixes = false,
							},
						},
					},
				},
			},
		},
		keys = {
			{
				"<leader>cw",
				add_word_to_dict,
				desc = "Spell: add word to dictionary",
			},
		},
	},
}
