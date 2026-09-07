{
  inputs,
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    google-chrome
    firefox
  ];
}
