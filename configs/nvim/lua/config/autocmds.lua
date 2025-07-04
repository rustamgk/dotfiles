-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-format on save for specific file types
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go", "*.py", "*.js", "*.ts", "*.json", "*.yaml", "*.yml", "*.tf", "*.hcl" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Set specific settings for YAML files (Kubernetes manifests)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Set specific settings for Terraform files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "terraform", "hcl" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Set specific settings for Go files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})
