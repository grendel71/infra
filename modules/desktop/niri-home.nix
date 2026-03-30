{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    #./theming-sway.nix
  ];
  home.packages = with pkgs; [
    #grim
    #waybar
    gpaste
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum

  ];
  #niri
  home.file.".config/niri".source =
    config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/niri";
  qt.enable = true;
  qt.platformTheme.name = "kvantum";
  qt.style.name = "kvantum";

  gtk.enable = true;

  gtk.cursorTheme.package = pkgs.bibata-cursors;
  gtk.cursorTheme.name = "Bibata-Modern-Ice";

  gtk.theme.package = pkgs.gruvbox-dark-gtk;
  gtk.theme.name = "gruvbox-dark";

  gtk.iconTheme.package = pkgs.gruvbox-dark-icons-gtk;
  gtk.iconTheme.name = "oomox-gruvbox-dark";

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=KvGnomeDark
  '';

  xdg.configFile."kdeglobals".text = ''
    [Icons]
    Theme=oomox-gruvbox-dark

    [General]
    BrowserApplication=xdg-open

    [KDE]
    OpenWithStyle=Open
  '';

}
