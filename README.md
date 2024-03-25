# randomquote.nvim

A simple and super minimal neovim startup screen plugin that displays a random quote from api.quotable.io.

<image src="https://raw.githubusercontent.com/kungfusheep/randomquote.nvim/master/assets/example.png">

## Features

- Super minimalistic, calming opening screen.
- Random quote from api.quotable.io.
- No dependencies.
- Provides a command to jump into the startup screen at any time.

## Installation

You can install the plugin using your preferred package manager, below is an example using Lazy:

```lua
{
    "kungfusheep/randomquote.nvim",
    event = "VimEnter",
    config = function()
        require("randomquote").setup()
    end
},
```

## Usage

The plugin is automatically triggered on startup. You can also manually trigger it using the `:RandomQuote` command.

## License

This plugin is released under the [MIT License](https://opensource.org/licenses/MIT).

](https://raw.githubusercontent.com/kungfusheep/randomquote.nvim/master/assets/example.png)
