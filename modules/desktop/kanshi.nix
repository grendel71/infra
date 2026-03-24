{ config, pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    kanshi
    
  ];

  home.file.".config/kanshi/".source = config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/kanshi";

  systemd.user.services.kanshi = {
    Unit = {
        Description = "kanshi daemon";
    };
    Install = {
        WantedBy = ["graphical-session.target"];
    };
    Service = {
        ExecStart = "${pkgs.kanshi}/bin/kanshi";
    };
  };
}