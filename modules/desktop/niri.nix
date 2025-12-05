{ config, pkgs, ... }:

{
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
	  xwayland-satellite
    #alacritty
    #sway
    #dbus-sway-environment
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
    #pcmanfm
    kdePackages.dolphin
  ];

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -ro";
        };
      };
    };
  };
}
