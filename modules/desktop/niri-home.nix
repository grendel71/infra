{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    #./theming-sway.nix
  ];
  home.packages = with pkgs; [
    #grim
    #waybar
	gpaste
  ];
  #niri
  home.file.".config/niri".source = config.lib.file.mkOutOfStoreSymlink "/home/blau/infra/dotfiles/niri";
  qt.enable = true;

# platform theme "gtk" or "gnome"
  qt.platformTheme = "gtk";

# name of the qt theme
  qt.style.name = "adwaita-dark";

# detected automatically:
# adwaita, adwaita-dark, adwaita-highcontrast,
# adwaita-highcontrastinverse, breeze,
# bb10bright, bb10dark, cde, cleanlooks,
# gtk2, motif, plastique

# package to use
  qt.style.package = pkgs.adwaita-qt;
  
  gtk.enable = true;

  gtk.cursorTheme.package = pkgs.bibata-cursors;
  gtk.cursorTheme.name = "Bibata-Modern-Ice";

  gtk.theme.package = pkgs.adw-gtk3;
  gtk.theme.name = "adw-gtk3-dark";

  gtk.iconTheme.package = pkgs.tango-icon-theme;
  gtk.iconTheme.name = "Tango";

}
