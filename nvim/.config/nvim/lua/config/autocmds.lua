local group = vim.api.nvim_create_augroup("kohta_autosave", { clear = true })

local skip_filetypes = {
  gitcommit = true,
  gitrebase = true,
}

local function should_save(buf)
  if vim.bo[buf].buftype ~= "" then return false end
  if not vim.bo[buf].modifiable or vim.bo[buf].readonly then return false end
  if skip_filetypes[vim.bo[buf].filetype] then return false end
  if vim.api.nvim_buf_get_name(buf) == "" then return false end
  return vim.bo[buf].modified
end

vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  callback = function(args)
    if should_save(args.buf) then
      vim.api.nvim_buf_call(args.buf, function()
        vim.cmd("silent! write")
      end)
    end
  end,
})
