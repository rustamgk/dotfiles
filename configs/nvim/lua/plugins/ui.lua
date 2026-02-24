-- UI and appearance customizations
return {
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
      },
    },
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_x = {
          {
            function()
              local msg = "No Active Lsp"
              local buf_ft = vim.bo.filetype
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if next(clients) == nil then
                return msg
              end
              for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                  return client.name
                end
              end
              return msg
            end,
            icon = " LSP:",
            color = { fg = "#ffffff", gui = "bold" },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    },
  },

  -- Better notifications
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    opts = {
      config = {
        header = {
          "                                                     ",
          "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
          "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
          "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
          "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
          "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
          "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
          "                                                     ",
          "          🚀 DevOps Development Environment           ",
        },
        center = {
          {
            icon = " ",
            desc = "Find File                               ",
            key = "f",
            action = "Telescope find_files",
          },
          {
            icon = " ",
            desc = "Recent Files                            ",
            key = "r",
            action = "Telescope oldfiles",
          },
          {
            icon = " ",
            desc = "Find Text                               ",
            key = "g",
            action = "Telescope live_grep",
          },
          {
            icon = " ",
            desc = "New File                                ",
            key = "n",
            action = "enew",
          },
          {
            icon = " ",
            desc = "File Explorer                           ",
            key = "e",
            action = "Neotree",
          },
          {
            icon = " ",
            desc = "Configuration                           ",
            key = "c",
            action = "edit ~/.config/nvim/init.lua",
          },
          {
            icon = "󰗼 ",
            desc = "Quit                                    ",
            key = "q",
            action = "qa",
          },
        },
      },
    },
  },
}
