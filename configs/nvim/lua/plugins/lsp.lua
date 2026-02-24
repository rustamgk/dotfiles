-- LSP configuration for DevOps tools
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- YAML Language Server
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              format = {
                enable = true,
              },
              validate = true,
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/github-action.json"] = "/.github/action.{yml,yaml}",
                ["https://json.schemastore.org/ansible-stable-2.9.json"] = "/roles/tasks/*.{yml,yaml}",
                ["https://json.schemastore.org/prettierrc.json"] = "/.prettierrc.{yml,yaml}",
                ["https://json.schemastore.org/kustomization.json"] = "/kustomization.{yml,yaml}",
                ["https://json.schemastore.org/ansible-playbook.json"] = "*play*.{yml,yaml}",
                ["https://json.schemastore.org/chart.json"] = "/Chart.{yml,yaml}",
                ["https://json.schemastore.org/dependabot-v2.json"] = "/.github/dependabot.{yml,yaml}",
                ["https://json.schemastore.org/gitlab-ci.json"] = "/.gitlab-ci.{yml,yaml}",
                ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
                ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
              },
            },
          },
        },

        -- Terraform Language Server
        terraformls = {
          filetypes = { "terraform", "tf" },
        },

        -- Docker Language Server
        dockerls = {
          filetypes = { "dockerfile" },
        },

        -- Bash Language Server
        bashls = {
          filetypes = { "sh", "bash" },
        },

        -- JSON Language Server
        jsonls = {
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },

        -- Go Language Server (additional settings)
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },

        -- Python Language Server
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
              },
            },
          },
        },
      },
    },
  },

  -- Additional formatters and linters
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        yaml = { "yamlfmt" },
        yml = { "yamlfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        go = { "goimports", "gofmt" },
        python = { "black", "isort" },
        json = { "jq" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        terraform = { "tflint" },
        tf = { "tflint" },
        yaml = { "yamllint" },
        yml = { "yamllint" },
        dockerfile = { "hadolint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        python = { "flake8" },
      },
    },
  },
}
