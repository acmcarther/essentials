#Alex's Linux Essentials

Mostly plug & play on NixOS. Uses xmonad for WM, lemonbar for status bar.


##Contents
- /bin -> Automatically src'd by .zshrc. Symlink things here
- /configuration.nix -> NixOs configuration file. Sets up the whole OS
- /dotfiles -> Dotfiles for the OS. Get linked via /script/sysinstall/link_dotfiles.sh
- /hardware-configuration.nix -> Disk configuration & hw config for Late 2015 Dell XPS 15
- /man -> Automatically src'd by .zshrc. Symlink man pages here
- /repo -> External repos useful for me. Contents linked into /bin
- /scripts -> Grab bag of random scripts I've found useful


##Details
Check out configuration.nix -- it lists the packages I have installed. Quick summary:
- Xmonad for WM
- Bunblebee for GFX
- urxvt for terminal emulator
- physlock for screen locker
- Thunar for file manager
- Chromium for browser


##Current Desktop
![](screenshot.png?raw=true)
