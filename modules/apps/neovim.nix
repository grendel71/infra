{ config, pkgs, ... }:
{
  home.packages = [ pkgs.neovim pkgs.tree-sitter ];

  programs.neovim = {
    defaultEditor = true;
  };
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/nvim";
}
