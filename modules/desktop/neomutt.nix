{ config, pkgs, lib, ... }:

{
  home.file.".neomutt/".source = config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/neomutt/";

  sops.secrets.neomutt = {
    sopsFile = ../../secrets/neomutt.yaml;
  };
}