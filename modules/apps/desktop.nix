{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    #discord
    vesktop
    #shotwell
    screenfetch
    firefox
    htop
    jetbrains.idea
    fuzzel
    obsidian
    nextcloud-client
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

    gimp
    # education
    # rstudio
    pandoc
    zed-editor
    ];
}
