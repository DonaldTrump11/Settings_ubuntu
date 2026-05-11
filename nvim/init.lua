-- Установка пакетного менеджера (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Настройки редактора
vim.opt.number = true           -- Нумерация строк
vim.opt.relativenumber = false   -- Относительная нумерация строк
vim.opt.syntax = "on"           -- Подсветка синтаксиса
vim.opt.mouse = "a"             -- Поддержка мыши
vim.opt.clipboard = "unnamedplus" -- Использование системного буфера обмена
vim.opt.tabstop = 8            -- Ширина табуляции
vim.opt.shiftwidth = 8         -- Ширина отступа
vim.opt.expandtab = false       -- Преобразование табов в пробелы
vim.opt.smartindent = true     -- Умные отступы
vim.opt.cursorline = true      -- Подсветка текущей строки

-- Клавиши для копирования/вставки через системный буфер
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true }) -- Ctrl+C в visual mode
vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, silent = true }) -- Ctrl+V в normal mode
vim.keymap.set("v", "<C-v>", '"+p', { noremap = true, silent = true }) -- Ctrl+V в visual mode
vim.keymap.set("i", "<C-v>", '<ESC>"+pa', { noremap = true, silent = true }) -- Ctrl+V в insert mode

-- Пакеты через lazy.nvim
require("lazy").setup({
  -- Treesitter для улучшенной подсветки синтаксиса
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "python" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end
  },

  -- Плагин для C++ с поддержкой LSP и автодополнения
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd" }
      })

      local lspconfig = require("lspconfig")
      lspconfig.clangd.setup({
        capabilities = require('cmp_nvim_lsp').default_capabilities()
      })

      -- Клавиши для LSP
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, {})
      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end
  },

  --[[
  -- Автодополнение
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  },
  ]]
  -- Сниппеты
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
  },

  -- Файловый менеджер
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {})
    end
  },

  -- Статусная строка
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "auto" }
      })
    end
  },

  -- Темы оформления
  { "navarasu/onedark.nvim" },
  { "ellisonleao/gruvbox.nvim" },
  { "rose-pine/neovim" },
})

-- Установка темы по умолчанию
vim.cmd.colorscheme("onedark")

-- Автокоманды для C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    -- Настройки для C++ файлов
    vim.opt_local.comments = [[:///:,://]]
    vim.opt_local.commentstring = "// %s"
  end,
})

-- Создание команд для компиляции и запуска C++ кода
vim.api.nvim_create_user_command("CompileRunCpp", function()
  local filename = vim.fn.expand("%")
  local output = vim.fn.expand("%:r")
  vim.cmd("!g++ -std=c++17 -Wall -Wextra -O2 " .. filename .. " -o " .. output)
  if vim.v.shell_error == 0 then
    print("Compilation successful!")
    vim.cmd("!./" .. output)
  end
end, {})

vim.api.nvim_create_user_command("DebugCpp", function()
  local filename = vim.fn.expand("%")
  local output = vim.fn.expand("%:r")
  vim.cmd("!g++ -std=c++17 -g " .. filename .. " -o " .. output)
  if vim.v.shell_error == 0 then
    print("Debug compilation successful!")
  end
end, {})

-- Горячие клавиши для C++
vim.keymap.set("n", "<F5>", ":CompileRunCpp<CR>", { silent = true })
vim.keymap.set("n", "<F6>", ":DebugCpp<CR>", { silent = true })

print("NVIM configuration loaded!")
