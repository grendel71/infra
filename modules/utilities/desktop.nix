{ config, pkgs, inputs, ... }:

{

  home.packages = with pkgs; [
    #discord
    #shotwell
    screenfetch
    firefox
    htop
    
    obsidian
    nextcloud-client
    vscodium

    thunderbird
    libreoffice-qt
    bitwarden-desktop
    mpv
    nomacs
    keepassxc
    vscodium
    #alacritty
    #waybar
    #wofi
        
    #xfce.thunar
    #dolphin
    qalculate-qt
    gimp
    kitty
    pavucontrol

    #moonlight-qt
    calibre

    ##fonts
    

    #xournalpp

    saber
    #zenity dependency of saber for export pdf
    zenity 
    handbrake
    #mail
    #neomutt


    # education
    # rstudio
    
    ];
}
