{ config, pkgs, lib, ... }:

{
  programs.waybar.enable = true;
  home.file.".config/niri".source = config.lib.file.mkOutOfStoreSymlink "/home/blau/dotfiles/waybar";
}