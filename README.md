# Don's Dotfiles

These are my personal configuration files. I hope to keep adding more in the
future; in the meantime, here's what I use to get things done.

I use GNU Stow to manage my dotfiles.


## Setting up a new machine

These steps are assuming that you are setting up a macOS device.

1. Clone this repo to your home folder (I generally go with `~/.dotfiles`.

   ```
   git clone git@github.com:DonQuinleone/Dotfiles.git ~/.dotfiles
   ```

2. Once that's done, run `./setup/_machine.sh`.
   This will setup everything automatically, including installing packages.

3. Install Packer for Neovim.

   ```
   git clone --depth 1 https://github.com/wbthomason/packer.nvim \
   ~/.local/share/nvim/site/pack/packer/start/packer.nvim
   ```

   NB. I know that Packer is unmaintained. I will switch at some point.

4. Install Neovim plugins via `:PackerInstall` in Neovim.

All done :-)

There will be a few more programs that need to be installed manually, but this
should be a good starter. Programs to remember:

* Adobe Creative Cloud
* Avid Pro Tools
* TakeLogger
* dbPowerAmp
* Steinberg Dorico
* Melodyne
* Other audio plugins

and of course any games or other tools that may be desired.

## Contributions

PRs are welcome, though I'll only merge in changes if I'm likely to use them myself.
