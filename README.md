# keymap.nvim

A lightweight Neovim plugin for creating key mappings with optional which-key integration.

## Features

- Simple API for creating key mappings
- Which-key integration with auto-fallback to native `vim.keymap.set`
- Support for buffer-local, filetype-specific, and buftype-specific mappings
- VSCode extension support
- Zero-dependency core (which-key optional)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "sohanemon/keymap.nvim",
  opts = {},
},
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use("sohanemon/keymap.nvim")
```

## Configuration

```lua
require("keymap").setup({
  default_icon = "",    -- Icon for which-key display
  wk_fallback = true,    -- Fallback to vim.keymap.set when which-key unavailable
})
```

## Usage

```lua
local keymap = require("keymap")

-- Basic key mapping
keymap.remap({
  key = "<leader>ff",
  action = ":Telescope find_files<CR>",
  desc = "Find files",
})

-- With which-key icon
keymap.remap({
  key = "<leader>fb",
  action = ":Telescope buffers<CR>",
  desc = "Buffers",
  icon = "",
})

-- Multiple modes
keymap.remap({
  key = "<leader>cd",
  action = ":cd %:p:h<CR>",
  desc = "Change directory",
  mode = { "n", "v" },
})

-- Buffer-local mapping
keymap.remap({
  key = "<leader>q",
  action = ":q<CR>",
  desc = "Quit",
  buffer = true,
})

-- Filetype-specific mapping
keymap.remap({
  key = "<leader>cc",
  action = ":Commentary<CR>",
  desc = "Comment",
  filetype = "python",
})

-- With function action
keymap.remap({
  key = "<leader>pp",
  action = function()
    vim.notify("Project panel")
  end,
  desc = "Show project panel",
})

-- With VSCode support
keymap.remap({
  key = "<leader>rn",
  action = "editor.action.rename",
  desc = "Rename",
  vscode = "editor.action.rename",
})

-- Send key sequence
keymap.send_key("<Esc>", "i")

-- Delete a keymap
keymap.delete_keymap("<leader>x", "n")
```

## API

### `keymap.remap(opts)`

Create a key mapping.

| Option | Type | Description |
|--------|------|-------------|
| `key` | `string` | Key sequence (required) |
| `action` | `string\|function` | Command or function (required) |
| `mode` | `string\|string[]` | Mode(s): "n", "i", "v", "x", "s", "o", "t" (default: "n") |
| `desc` | `string` | Description for which-key |
| `remap` | `boolean` | Allow remapping |
| `buffer` | `boolean\|number` | Buffer-local mapping |
| `filetype` | `string\|string[]` | Filetype pattern(s) |
| `buftype` | `string\|string[]` | Buftype pattern(s) |
| `icon` | `string` | Icon for which-key |
| `vscode` | `string` | VSCode command |

### `keymap.send_key(key, mode)`

Send key sequence to Vim.

### `keymap.delete_keymap(key, mode)`

Delete an existing key mapping.

### `keymap.setup(opts)`

Configure plugin defaults.

## License

MIT
