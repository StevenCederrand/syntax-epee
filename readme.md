## Syntax Épée

Syntax Épée is a simple plugin that fetches all lsp diagnostics and displays them within a selectable window.

### Pre-reqs
* **nerdfonts**: are a must

## Installation
You can install Syntax Épée using Packer and Lazy.

### With Packer
`use 'stevencederrand/syntax-epee'`

### With Lazy
[See configs](https://github.com/StevenCederrand/configs/blob/master/nvim/lua/core/lazy.lua)

## Configuration

Syntax Épée is a very barebones plugin, and therefore doesn't require any settings. I would suggest setting up
`leader e` as keybinding for opening the menu.

``` lua
require("syntax-epee").setup()
vim.keymap.set("n", "<leader>e", function() require("syntax-epee").stab() end)
```
## Demo

![syntax-epee](https://github.com/user-attachments/assets/471b9eff-0ee3-49fc-a659-48dd5d88fa86)




