{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    bun
    unstable.opencode
    unstable.opencode-desktop
  ];
  home.file.".config/opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/opencode/opencode.json";
}
