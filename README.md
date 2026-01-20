# keymap.nvim

A lightweight Neovim plugin for creating key mappings with buffer, filetype, and buftype scoping.

## Why keymap.nvim?

Most keymapping plugins give you global mappings. This plugin makes it **trivial to create context-aware keymaps** that only exist where you need them — per buffer, per filetype, or per buftype.

No more cluttering your config with `autocmd` boilerplate. Just declare where a keymap should apply.

## Features

- **Buffer-local mappings** — Keymaps that live only in the current buffer
- **Filetype-specific mappings** — Keymaps that activate only for specific file types
- **Buftype-specific mappings** — Keymaps for special buffer types (quickfix, terminal, etc.)
- Simple API with optional which-key integration
- Zero-dependency core (which-key optional)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "sohanemon/keymap.nvim",
  opts = {},
}
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

Use either the module pattern or the global `Keymap` table:

```lua
-- Module pattern (recommended)
local keymap = require("keymap")
keymap.remap({ ... })

-- Global pattern
Keymap.remap({ ... })

-- Global key mapping (applies everywhere)
keymap.remap({
  key = "<leader>ff",
  action = ":Telescope find_files<CR>",
  desc = "Find files",
})

-- Buffer-local: only in the buffer where you call it
keymap.remap({
  key = "<leader>q",
  action = ":q<CR>",
  desc = "Quit",
  buffer = true,
})

-- Filetype-specific: only for Python files
keymap.remap({
  key = "<leader>cc",
  action = ":Commentary<CR>",
  desc = "Comment",
  filetype = "python",
})

-- Multiple filetypes at once
keymap.remap({
  key = "<leader>fm",
  action = ":Format<CR>",
  desc = "Format",
  filetype = { "python", "lua", "javascript" },
})

-- Buftype-specific: only in quickfix buffers
keymap.remap({
  key = "<leader>x",
  action = ":cclose<CR>",
  desc = "Close quickfix",
  buftype = "quickfix",
})

-- Multiple modes
keymap.remap({
  key = "<leader>cd",
  action = ":cd %:p:h<CR>",
  desc = "Change directory",
  mode = { "n", "v" },
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
