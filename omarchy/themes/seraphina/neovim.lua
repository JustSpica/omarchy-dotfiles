return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#171023",
        dark_bg    = "#110c1a",
        darker_bg  = "#0c0812",
        lighter_bg = "#2e2839",

        fg         = "#debfe6",
        dark_fg    = "#a78fad",
        light_fg   = "#e3c9ea",
        bright_fg  = "#e6cfec",
        muted      = "#5d5378",

        red        = "#c591d4",
        yellow     = "#ddb3ed",
        orange     = "#cea2da",
        green      = "#b0b1f4",
        cyan       = "#b4b5f7",
        blue       = "#9ca1e6",
        purple     = "#d99ad8",
        brown      = "#7c6183",

        bright_red    = "#e8b5fb",
        bright_yellow = "#f2bdff",
        bright_green  = "#c3bfff",
        bright_cyan   = "#c6c2ff",
        bright_blue   = "#c5c7ff",
        bright_purple = "#f4b7f9",

        accent               = "#9ca1e6",
        cursor               = "#debfe6",
        foreground           = "#debfe6",
        background           = "#171023",
        selection             = "#2e2839",
        selection_foreground = "#debfe6",
        selection_background = "#2e2839",
      },
    },
    -- set up hot reload
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
