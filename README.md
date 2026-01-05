# YuriLand - Hyprland Dotfiles
These are my Hyprland configuration files in .config/hypr/ directory. Other files are the config for software like foot, fish, rofi etc. but they will have their own GitHub repo; important thing is that my repo YuriTheme contains a software that write these just mentioned files using a palette according desktop background.
My OS is Arch Linux and I use hyprland-git by AUR launched by UWSM (check https://wiki.hyprland.org/ for details, UWSM let things like systemd services work with Hyprland) by SDDM (cool themes for SDDM you can find [here](https://github.com/hiki-uwu/sddm-theme/tree/master)).

## Dependencies

See `requirements.txt` for the full list of dependencies.

### Installation (Arch Linux)

Install all dependencies with yay (or paru):

```bash
paru -S --needed hyprland hyprlock hyprpaper hypridle ptyxis nemo wofi swww flameshot fcitx5 pulseaudio pavucontrol playerctl polkit-gnome dbus xorg-xrdb copyq nomacs firefox
```

#### Optional packages

```bash
# ASUS ROG laptop tools
yay -S rog-control-center asusctl

# RGB lighting
yay -S openrgb

# Caelestia shell (follow instructions at https://github.com/caelestia-dots/shell)
```