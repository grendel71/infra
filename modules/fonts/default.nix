{ config, pkgs, ... }:

{
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
        vista-fonts
        corefonts
        font-awesome
        uget
    ];
}