# better-gtd.nvim

> A smarter go-to-definition plugin for Neovim with intelligent window management

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Neovim](https://img.shields.io/badge/neovim-0.9%2B-green.svg)

`better-gtd.nvim` enhances the default `gd` (go to definition) behavior by opening definitions in vertical splits with smart window management. It keeps your context visible while exploring code definitions.

## ✨ Features

- **Smart Vertical Split Navigation** - Opens definitions in vertical splits instead of replacing the current window
- **Intelligent Window Reuse** - Reuses existing vertical splits when possible to maintain clean layout
- **Same-File Optimization** - Direct cursor movement for definitions within the current buffer
- **Version Compatibility** - Supports both Neovim v0.9+ and v0.10+ with optimized implementations
- **Seamless LSP Integration** - Works with any LSP server that supports `textDocument/definition`
- **Clean Layout Management** - Prevents window clutter by reusing available splits

## 📦 Installation

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'mkeiji/better-gtd.nvim'
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'mkeiji/better-gtd.nvim'
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup {
  'mkeiji/better-gtd.nvim',
  config = function()
    require('better-gtd').setup()
  end
}
```

## 🚀 Usage

### Basic Setup

```lua
require('better-gtd').setup()
```

After setup, the plugin automatically binds `gd` to the enhanced go-to-definition function.

### Manual Keybinding

If you prefer a different keybinding or want more control:

```lua
vim.keymap.set('n', 'gd', function()
  require('better-gtd').impl.go_to_definition()
end, { desc = 'Better GTD: go to definition' })
```

## 🔧 Configuration

Currently, the plugin works out-of-the-box with sensible defaults. Future versions may include configuration options for:

- Preferred split direction (vertical/horizontal)
- Window reuse behavior
- Custom keybindings

## 🎯 How It Works

1. **Same File Definition**: If the definition is in the current buffer, the plugin moves the cursor directly (no split created).

2. **Different File Definition**: 
   - Checks if the target file is already open in an existing window → jumps to that window
   - Looks for an existing vertical split to reuse → opens the definition there
   - Creates a new vertical split if no suitable window exists

3. **Version Optimization**:
   - **Neovim v0.10+**: Uses the modern `vim.lsp.buf.definition` with `on_list` callback
   - **Neovim v0.9+**: Uses the traditional LSP handler override approach

## 📋 Compatibility

| Neovim Version | Implementation | Status |
|----------------|----------------|--------|
| 0.10+          | Modern         | ✅ Supported |
| 0.9.x          | Legacy         | ✅ Supported |
| < 0.9          | -              | ❌ Not supported |

## 🔄 Comparison with Default `gd`

| Feature | Default `gd` | `better-gtd.nvim` |
|---------|---------------|-------------------|
| Opens in current window | ✅ | ❌ (opens in split) |
| Maintains context | ❌ | ✅ |
| Reuses existing windows | ❌ | ✅ |
| Smart window management | ❌ | ✅ |
| Cross-version compatibility | ✅ | ✅ |

## 🤝 Contributing

I only plan to keep minimal maintenance on this plugin (except for breaking changes in the Neovim API).
BUT, contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need for better code navigation in Neovim
- Built to work seamlessly with Neovim's built-in LSP client
- Thanks to the Neovim community for the excellent plugin ecosystem

---