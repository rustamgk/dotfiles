-- DevOps and Infrastructure related plugins
return {
  -- Kubernetes YAML support
  {
    "someone-stole-my-name/yaml-companion.nvim",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
  },

  -- Helm support
  {
    "towolf/vim-helm",
    ft = "helm",
  },

  -- Enhanced Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  -- Docker syntax highlighting
  {
    "ekalinin/Dockerfile.vim",
    ft = "dockerfile",
  },

  -- Terraform additional features
  {
    "hashivim/vim-terraform",
    ft = "terraform",
    config = function()
      vim.g.terraform_align = 1
      vim.g.terraform_fold_sections = 1
      vim.g.terraform_fmt_on_save = 1
    end,
  },

  -- NGINX configuration syntax
  {
    "chr4/nginx.vim",
    ft = "nginx",
  },

  -- Markdown preview for documentation
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- REST client for API testing (rest-nvim v2 API)
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("rest-nvim").setup()
    end,
    keys = {
      { "<leader>rr", "<cmd>Rest run<cr>",      desc = "Run REST request" },
      { "<leader>rl", "<cmd>Rest run last<cr>", desc = "Re-run last REST request" },
    },
  },
}
