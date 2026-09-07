{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # configure options
  programs.noctalia = {
    enable = true;
  };

  home.file.".config/noctalia".source =
    config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/noctalia";
}
