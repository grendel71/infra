{ config, pkgs, ... }:
{
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
	  xwayland-satellite
    #alacritty
    #sway
    #dbus-niri-environment
    #configure-gtk
    wayland
    xdg-utils
    glib
    #whitesur-icon-theme
    #grim
    slurp
    wl-clipboard
    capitaine-cursors
    waypaper
    swaybg
    kitty
    wofi
    pcmanfm
    #kdePackages.dolphin
  ];

  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sway.enableGnomeKeyring = true;
  

  programs.xfconf.enable = true;
}
