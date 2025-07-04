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

  -- REST client for API testing
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("rest-nvim").setup({
        result_split_horizontal = false,
        result_split_in_place = false,
        skip_ssl_verification = false,
        encode_url = true,
        highlight = {
          enabled = true,
          timeout = 150,
        },
        result = {
          show_url = true,
          show_http_info = true,
          show_headers = true,
          formatters = {
            json = "jq",
            html = function(body)
              return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
            end
          },
        },
      })
    end
  },
}
