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
- Global `Keymap` table for convenience

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)


```lua
{
  "sohanemon/keymap.nvim",
  dependencies = { "folke/which-key.nvim"  }, -- optional
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use("sohanemon/keymap.nvim")
```

## Configuration

**String (same icon for all):**

```lua
require("keymap").setup({
  icon = "",  -- Icon for which-key (keymaps and groups)
})
```

**Table (different icons for keymaps and groups):**

```lua
require("keymap").setup({
  icon = {
    default = "",   -- Icon for keymaps
    group = "",     -- Icon for groups
  },
})
```

Or pass opts to lazy.nvim:

```lua
{
  "sohanemon/keymap.nvim",
  opts = {
    icon = {
      default = "",
      group = "",
    },
  },
}
```

## Usage

Use either the module pattern or the global `Keymap` table:

```lua
-- Module pattern (recommended)
local keymap = require("keymap")
keymap.add({ ... })

-- Global pattern
Keymap.add({ ... })
```

### Global Key Mapping

```lua
keymap.add({
  key = "<leader>ff",
  action = ":Telescope find_files<CR>",
  desc = "Find files",
})
```

### Buffer-local Mapping

Keymaps that live only in the current buffer:

```lua
keymap.add({
  key = "<leader>q",
  action = ":q<CR>",
  desc = "Quit",
  buffer = true,
})
```

### Filetype-specific Mapping

Keymaps that activate only for specific file types:

```lua
keymap.add({
  key = "<leader>cc",
  action = ":Commentary<CR>",
  desc = "Comment",
  filetype = "python",
})
```

Multiple filetypes:

```lua
keymap.add({
  key = "<leader>fm",
  action = ":Format<CR>",
  desc = "Format",
  filetype = { "python", "lua", "javascript" },
})
```

### Buftype-specific Mapping

Keymaps for special buffer types:

```lua
keymap.add({
  key = "<leader>x",
  action = ":cclose<CR>",
  desc = "Close quickfix",
  buftype = "quickfix",
})
```

### Multiple Modes

```lua
keymap.add({
  key = "<leader>cd",
  action = ":cd %:p:h<CR>",
  desc = "Change directory",
  mode = { "n", "v" },
})
```

### With VSCode Support

```lua
keymap.add({
  key = "<leader>rn",
  action = ":lua vim.lsp.buf.rename()", -- Neovim command
  vscode = "editor.action.rename", -- VSCode command
  desc = "Rename",
})
```

### With Function Action

```lua
keymap.add({
  key = "<leader>pp",
  action = function()
    vim.notify("Project panel")
  end,
  desc = "Show project panel",
})
```

### Create Which-key Group

When `action` is omitted, creates a which-key group with `desc` as the group name:

```lua
-- Group leader (no action, just a label)
keymap.add({
  key = "<leader>f",
  desc = "Telescope files",
})

-- Actual mappings under the group
keymap.add({
  key = "<leader>ff",
  action = ":Telescope find_files",
  desc = "Find files",
})

keymap.add({
  key = "<leader>fb",
  action = ":Telescope buffers",
  desc = "Buffers",
})
```

### Send Key Sequence

```lua
keymap.send_key("<Esc>", "i")
```

### Delete a Keymap

```lua
keymap.delete("<leader>x", "n")
```

## API

### `keymap.add(opts)`

Create a key mapping. If `action` is omitted, creates a which-key group with `desc` as the group name.

| Option | Type | Description |
|--------|------|-------------|
| `key` | `string` | Key sequence (required) |
| `action` | `string\|function` | Command or function (optional - omit to create a group) |
| `buffer` | `boolean\|number` | Buffer-local mapping |
| `filetype` | `string\|string[]` | Filetype pattern(s) |
| `buftype` | `string\|string[]` | Buftype pattern(s) |
| `mode` | `string\|string[]` | Mode(s): "n", "i", "v", "x", "s", "o", "t" (default: "n") |
| `desc` | `string` | Description for which-key, or group name if `action` is omitted |
| `remap` | `boolean` | Allow remapping |
| `icon` | `string` | Icon for which-key (only used if which-key is available) |
| `vscode` | `string` | VSCode command |

### `keymap.send_key(key, mode)`

Send key sequence to Vim.

### `keymap.delete(key, mode)`

Delete an existing key mapping.

### `keymap.setup(opts)`

Configure plugin defaults.

## License

MIT
