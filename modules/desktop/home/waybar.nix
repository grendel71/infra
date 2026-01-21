{ config, pkgs, lib, ... }:

{
  programs.waybar.enable = true;
  home.file.".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "/home/blau/dotfiles/waybar";
}