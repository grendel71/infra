{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    bun
    unstable.opencode
    unstable.opencode-desktop
    inputs.pi.packages.${pkgs.system}.pi
  ];
  home.file.".config/opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/opencode/opencode.json";
}
