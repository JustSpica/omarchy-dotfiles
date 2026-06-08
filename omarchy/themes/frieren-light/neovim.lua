return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#e3d8bc",
        dark_bg    = "#b79f70",
        darker_bg  = "#826e48",
        lighter_bg = "#e6dcc3",

        fg         = "#3c4747",
        dark_fg    = "#3c4747",
        light_fg   = "#465353",
        bright_fg  = "#3c4747",
        muted      = "#b79f70",

        red        = "#4F351E",
        yellow     = "#826e48",
        orange     = "#966133",
        green      = "#3A443D",
        cyan       = "#7B826D",
        blue       = "#1C2121",
        purple     = "#764E27",
        brown      = "#4F351E",

        bright_red    = "#966133",
        bright_yellow = "#b59d71",
        bright_green  = "#637669",
        bright_cyan   = "#a8ae9d",
        bright_blue   = "#465353",
        bright_purple = "#c17c38",

        accent               = "#1C2121",
        cursor               = "#3c4747",
        foreground           = "#3c4747",
        background           = "#e3d8bc",
        selection             = "#e6dcc3",
        selection_foreground = "#3c4747",
        selection_background = "#e6dcc3",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
