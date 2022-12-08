# cmp-latex-symbols

Add latex symbol support for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

![cmp-latex-symbols mov](https://user-images.githubusercontent.com/1813121/130020846-83996c11-b8a6-42a1-ac84-4b16af88a3cb.gif)

## Install

Using Packer:

```lua
use({
  "hrsh7th/nvim-cmp",
  requires = {
    { "kdheepak/cmp-latex-symbols" },
  },
  sources = {
    {
      name = "latex_symbols",
      option = {
        strategy = 0, -- mixed
      },
    },
  },
})
```

## Options

### `strategy`

Set the display strategy.

Type: number
Default: `0 -- mixed`
Possible values:

- `0 -- mixed` Show the command and insert the symbol
- `1 -- julia` Show and insert the symbol
- `2 -- latex` Show and insert the command

Original based on [compe-latex-symbols](https://github.com/GoldsteinE/compe-latex-symbols/).

Currently uses [`unimathsymbols.txt`](http://milde.users.sourceforge.net/LUCR/Math/data/unimathsymbols.txt) and LaTeX symbols defined by the Julia REPL.
For emoji's, use [this source](https://github.com/hrsh7th/cmp-emoji).

[See @ExpandingMan's repo](https://gitlab.com/ExpandingMan/cmp-latex/) for a source with all and only the latex and emoji symbols defined by the Julia REPL.
