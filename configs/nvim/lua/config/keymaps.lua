-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- DevOps specific keymaps
map("n", "<leader>dk", "<cmd>!kubectl get pods<cr>", { desc = "Get Kubernetes pods" })
map("n", "<leader>dh", "<cmd>!helm list<cr>", { desc = "List Helm releases" })
map("n", "<leader>dt", "<cmd>!terraform plan<cr>", { desc = "Terraform plan" })
map("n", "<leader>dg", "<cmd>!go test ./...<cr>", { desc = "Run Go tests" })

-- Docker related
map("n", "<leader>db", "<cmd>!docker build -t . .<cr>", { desc = "Docker build" })
map("n", "<leader>dr", "<cmd>!docker run<cr>", { desc = "Docker run" })

-- Git shortcuts
map("n", "<leader>gs", "<cmd>!git status<cr>", { desc = "Git status" })
map("n", "<leader>gl", "<cmd>!git log --oneline -10<cr>", { desc = "Git log" })

-- YAML/JSON formatting
map("n", "<leader>yf", "<cmd>%!yq eval '.' -<cr>", { desc = "Format YAML with yq" })
map("n", "<leader>jf", "<cmd>%!jq .<cr>", { desc = "Format JSON with jq" })

-- Quick terminal
map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
