{ config, pkgs, lib, ... }:

{
  home.file.".config/.muttrc".source = config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/neomutt/config";
}