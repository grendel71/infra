{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.niri.enable = true;
  nixpkgs.overlays = [ inputs.dolphin-overlay.overlays.default ];
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
    kdePackages.dolphin
  ];

  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sway.enableGnomeKeyring = true;

  programs.xfconf.enable = true;
}
