{
  config,
  pkgs,
  ...
}:
{
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    wayland
    xdg-utils
    glib
    grim
    slurp
    wl-clipboard
    capitaine-cursors
    waypaper
    swaybg
    kitty
    nautilus
  ];

  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sway.enableGnomeKeyring = true;

  programs.xfconf.enable = true;
}
