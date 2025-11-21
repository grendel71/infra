{ config, lib, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
      texliveFull
      (pkgs.rstudioWrapper.override {
      packages = with pkgs.rPackages; [
        ggplot2
        dplyr
        xts
        rmarkdown
        stringi
        stringr
      ];
    })

    ];
}