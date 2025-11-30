{ config, pkgs, ... }:

{
  imports = [
    ./modules/utilities
    ./modules/fonts
    ./modules/desktop/sway-home.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "blau";
  home.homeDirectory = "/home/blau";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
      
  ];
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      [[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh" 
    '';
    shellAliases = {
      please = "sudo";
      mail = "notmuch new; neomutt";
      rebuild = "sudo nixos-rebuild switch --flake $HOME/infra/";
      nsway = "sway --unsupported-gpu";
    };
  };

  programs.git = {
    enable = true;
    userName = "brandonlau6";
    userEmail = "brandonctx0@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
    extraConfig = {
      init.defaultBranch = "main";

    };
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
    ];
  };
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dominic/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.mimeApps ={
    enable = true;
defaultApplications = {
  "application/gzip" = "com.github.xournalpp.xournalpp.desktop";
  "application/pdf" = [
    "firefox.desktop"
  ];
  "application/x-matroska" = "mpv.desktop";
  "audio/aac" = "mpv.desktop";
  "audio/mp4" = "mpv.desktop";
  "audio/mpeg" = "mpv.desktop";
  "audio/mpegurl" = "mpv.desktop";
  "audio/ogg" = "mpv.desktop";
  "audio/vnd.rn-realaudio" = "mpv.desktop";
  "audio/vorbis" = "mpv.desktop";
  "audio/x-flac" = "mpv.desktop";
  "audio/x-mp3" = "mpv.desktop";
  "audio/x-mpegurl" = "mpv.desktop";
  "audio/x-ms-wma" = "mpv.desktop";
  "audio/x-musepack" = "mpv.desktop";
  "audio/x-oggflac" = "mpv.desktop";
  "audio/x-pn-realaudio" = "mpv.desktop";
  "audio/x-scpls" = "mpv.desktop";
  "audio/x-vorbis" = "mpv.desktop";
  "audio/x-vorbis+ogg" = "mpv.desktop";
  "audio/x-wav" = "mpv.desktop";

  "image/jpeg" = [
    "org.nomacs.ImageLounge.desktop"
    "org.gnome.Shotwell-Viewer.desktop"
  ];
  "image/png" = "org.nomacs.ImageLounge.desktop";
  "inode/directory" = "pcmanfm.desktop";
  "text/plain" = "codium.desktop";
  "video/3gp" = "mpv.desktop";
  "video/3gpp" = "mpv.desktop";
  "video/3gpp2" = "mpv.desktop";
  "video/avi" = "mpv.desktop";
  "video/divx" = "mpv.desktop";
  "video/dv" = "mpv.desktop";
  "video/fli" = "mpv.desktop";
  "video/flv" = "mpv.desktop";
  "video/mp2t" = "mpv.desktop";
  "video/mp4" = "mpv.desktop";
  "video/mp4v-es" = "mpv.desktop";
  "video/mpeg" = "mpv.desktop";
  "video/msvideo" = "mpv.desktop";
  "video/ogg" = "mpv.desktop";
  "video/quicktime" = "mpv.desktop";
  "video/vnd.divx" = "mpv.desktop";
  "video/vnd.mpegurl" = "mpv.desktop";
  "video/vnd.rn-realvideo" = "mpv.desktop";
  "video/webm" = "mpv.desktop";
  "video/x-avi" = "mpv.desktop";
  "video/x-flv" = "mpv.desktop";
  "video/x-m4v" = "mpv.desktop";
  "video/x-matroska" = "mpv.desktop";
  "video/x-mpeg2" = "mpv.desktop";
  "video/x-ms-asf" = "mpv.desktop";
  "video/x-ms-wmv" = "mpv.desktop";
  "video/x-ms-wmx" = "mpv.desktop";
  "video/x-msvideo" = "mpv.desktop";
  "video/x-ogm" = "mpv.desktop";
  "video/x-ogm+ogg" = "mpv.desktop";
  "video/x-theora" = "mpv.desktop";
  "video/x-theora+ogg" = "mpv.desktop";

  "x-scheme-handler/mailto" = "userapp-Thunderbird-I99ND3.desktop";
  "x-scheme-handler/mid" = "userapp-Thunderbird-I99ND3.desktop";
};
  };
}
