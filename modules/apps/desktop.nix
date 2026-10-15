{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    vesktop
    #shotwell
    screenfetch
    htop
    jetbrains.idea
    #fuzzel
    obsidian
    nextcloud-client
    waybar
    thunderbird
    libreoffice-qt
    inputs.pluely.packages.${pkgs.system}.cheating-daddy
    element-desktop
    #
    # bitwarden-desktop
    mpv
    nomacs
    keepassxc
    #vscodium
    #alacritty
    #waybar
    #wofi
    keepassxc
    #xfce.thunar
    #nautilus
    qalculate-qt
    #gimp
    kitty
    pavucontrol
    moonlight-qt
    calibre
    openshot-qt
    ffmpeg
    ##fonts
    octave

    #xournalpp

    saber
    #zenity dependency of saber for export pdf
    zenity
    handbrake
    #mail
    #neomutt
    #librewolf-bin-unwrapped
    gimp
    # education
    # rstudio
    pandoc
    #zed-editor
    sioyek

    protonup-qt
  ];
}
