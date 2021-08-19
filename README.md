# cmp-latex-symbols

Add latex symbol support for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

![cmp-latex-symbols mov](https://user-images.githubusercontent.com/1813121/130020846-83996c11-b8a6-42a1-ac84-4b16af88a3cb.gif)

```lua
use({
  "hrsh7th/nvim-cmp",
  requires = {
    { "kdheepak/cmp-latex-symbols" },
  },
  sources = {
    { name = "latex_symbols" },
  },
})
```

Based on [compe-latex-symbols](https://github.com/GoldsteinE/compe-latex-symbols/).
