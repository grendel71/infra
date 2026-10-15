{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    logisim
    logisim-evolution
  ];
}
