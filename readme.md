## Syntax Épée

Syntax Épée let's one view all of the lsp errors/warnings/info/hints in the file you are currently
working in. This builds upon telescope in order to display and filter the messages.

### Pre-reqs
* **nerdfonts**: are a must
* **telescope**: this plugin is build on telescope, so you will need that too

## Installation
You can install Syntax Épée using packer.

`use 'stevencederrand/syntax-epee'`

## Configuration
Syntax Épée is a very barebones plugin. You can use the following to setup `leader e` as your hotkey
for using Syntax Épée.

``` lua
require("syntax-epee").setup()
vim.keymap.set("n", "<leader>e", function() require("syntax-epee").stab() end)
```
## Demo

![syntax-epee](https://github.com/StevenCederrand/syntax-epee/assets/17464114/593c38f4-93a2-4eb9-bb6f-9d25457518dd)
