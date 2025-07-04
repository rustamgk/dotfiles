-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- General settings
opt.relativenumber = true -- Relative line numbers
opt.wrap = false -- Disable line wrap
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Tab settings
opt.tabstop = 4 -- Number of spaces tabs count for
opt.shiftwidth = 4 -- Size of an indent
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically

-- Search settings
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Don't ignore case with capitals
opt.hlsearch = false -- Don't highlight search results

-- Editor appearance
opt.termguicolors = true -- True color support
opt.signcolumn = "yes" -- Always show signcolumn
opt.cursorline = true -- Highlight current line
opt.colorcolumn = "80,120" -- Show column rulers

-- File handling
opt.backup = false -- Don't create backup files
opt.writebackup = false -- Don't create backup before overwriting
opt.swapfile = false -- Don't create swap files
opt.undofile = true -- Enable persistent undo

-- Split behavior
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- DevOps specific settings
opt.conceallevel = 0 -- Show all text normally (important for JSON/YAML)
opt.fileformat = "unix" -- Use Unix line endings
opt.fileformats = "unix,dos" -- Prefer Unix, fallback to DOS

-- Performance
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 300 -- Faster key sequence completion

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard
