return {
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
    },
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle Outline open/shut" },
    },
    opts = {
      -- Put opts here bby
    },
  },
  {
    "mbbill/undotree",
    lazy = true,
    keys = {
      { "<leader>cu", "<cmd>UndotreeToggle<cr>", desc = "Toggle undotree" },
    },
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        PIXNOTE = { icon = "N", color = "test", alt = { "THOUGHT" } },
        PIXHACK = { icon = "? ", color = "hint", alt = { "HACKFIX" } },
      },
    },
  },
}
