{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea
  ];
  programs.java.enable = true;
}