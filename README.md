# Dotfiles

Cleaned-up Dotfiles 2021 - not meant to be forked, but meant to inspire.

## Credits

Makefile and dotfile layout inspired by Stephen Celis' DotFiles: https://github.com/stephencelis/dotfiles

# Installation

1. Clone the dotfiles either directly into the home directory or somewhere else

```
git clone https://github.com/PatTheMav/Dotfiles.git
```

2. Run `make install` to install the default environment

# Update

Run `make update` followed by `make clean` to update the whole environment. Alternatively just run `make` which will invoke both automatically.

# Default Features

* Automatically installs Homebrew on macOS or Linux
    * Disable Homebrew by adding a file `.nobrew` in the checkout directory
    * Falls back to `apt` (*Linux only*)
* Installs Homebrew formulas, taps, and casks automatically
* Installs vim with `vim-plug` and `Airline` (and other plugins).
* Makes SF Mono available for other applications in (*macOS only*)
* Disables signing for SMB connections (*macOS only* - use at your own risk)
* Enables additional gestures (*macOS only*)

# Development Tools

Development tools for specific languages have their own make targets, e.g.:

| Language  | Target | Notes |
| :--- | :---: | :--- |
| PHP | `make php`/`php_dev`  | Includes PHP language server. PHP installed with pear extensions |
| Python | `make python`/`python_dev`  | Includes Python language server. Installs as Python3 site package. |
| Javascript | `make node`/`node_dev` | Includes Javascript/Typescript language server and CSS/JS compression tools. |

# Shells

Updated shells can be installed via Homebrew. Both will be preconfigured with frameworks/extras:

| Shell  | Target | Notes |
| :--- | :---: | :--- |
| BASH  | `make bash`  | Includes bash-extras |
| ZSH  | `make zsh`  | Includes zim framework, minimal2 and Powerlevel10k theme and zimfw-extras. |
