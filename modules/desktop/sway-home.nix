{ config, pkgs, lib, ... }:

{
  imports = [
    #./theming-sway.nix
  ];
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    
    systemdIntegration = true;


  };
  #xdg.configFile."sway/config".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink ./config);

  #xdg.configFile = {
  #  "sway/config".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink ./config);
  #  "waybar/config".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink ./waybar);
  #};  

  home.packages = with pkgs; [
    grim
    waybar
  ];

  home.file."${config.xdg.configHome}" = {
  source = ../../dotfiles;
  recursive = true;
};

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