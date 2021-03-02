# Dotfiles
---
Cleaned-up Dotfiles 2020 - not meant to be forked, but meant to inspire.

## Credits

Makefile and dotfile layout inspired by Stephen Celis' DotFiles: https://github.com/stephencelis/dotfiles

*Still work in progress*

# Installation

1. Clone the dotfiles either directly into the home directory or somewhere else

```
git clone --recursive https://github.com/PatTheMav/Dotfiles.git
```

2. Run `make install` to install the default environment

# Update

Run `make update` followed by `make clean` to update the whole environment. Alternatively just run `make` which will invoke both automatically.

# Default Features

* Automatically installs Homebrew (macOS for now, *TODO*: Linux Homebrew and Windows Scoop), Python3 and VIM.
    * VIM uses `vim-plug` by default with `Airline` (and other plugins).
* Makes San Francisco Mono available for other applications in macOS
* `Terminal.app` theme inspired by Sublime Text 3's new "Mariana Theme"
* Disables signing for SMB connections in macOS (use at your own risk - SMB shouldn't be used over an open wire anyway..)
* Enables additional gestures for the macOS dock

# Development Tools

Development tools for specific languages have their own make targets, e.g.:

| Language  | Target | Notes |
| :--- | :---: | :--- |
| PHP 7.2  | `make php`  | Includes `composer` and PHP language server. PHP installed with pear extensions |
| Python 3.6  | `make python`  | Includes Python language server. Installs as Python3 site package. |
| Javascript | `make node` | Includes Javascript/Typescript language server and CSS/JS compression tools. |

# Shells

Updated shells can be installed via Homebrew. Both will be preconfigured with frameworks/extras:

| Shell  | Target | Notes |
| :--- | :---: | :--- |
| BASH  | `make bash`  | Includes bash-extras (*TODO*) |
| ZSH  | `make zsh`  | Includes zim framework, minimal2 theme and zimfw-extras. |
