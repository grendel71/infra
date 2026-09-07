{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.yazi
    pkgs.rich-cli
  ];

  home.file.".config/yazi".source =
    config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/yazi";
}
