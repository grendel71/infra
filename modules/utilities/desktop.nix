{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    discord
    #shotwell
    screenfetch
    firefox
    htop
    fuzzel   
    obsidian
    nextcloud-client
    vscodium
    waybar
    thunderbird
    libreoffice-qt
    bitwarden-desktop
    mpv
    nomacs
    keepassxc
    #vscodium
    #alacritty
    #waybar
    #wofi
        
    #xfce.thunar
    #dolphin
    qalculate-qt
    #gimp
    kitty
    pavucontrol

    #moonlight-qt
    calibre

    ##fonts
    octave

    #xournalpp

    saber
    #zenity dependency of saber for export pdf
    zenity 
    handbrake
    #mail
    #neomutt


    # education
    # rstudio
    pandoc
    
    ];
}
