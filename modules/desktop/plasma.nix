{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  #services.displayManager.sddm.wayland.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    oxygen
    kate
    elisa
  
  ];
  environment.systemPackages = with pkgs;
  [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    #kde-gruvbox
    polonium
    kitty
];
}
