{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-python.python
      ocamllabs.ocaml-platform
      ms-kubernetes-tools.vscode-kubernetes-tools
      vscjava.vscode-java-pack
      james-yu.latex-workshop
      anthropic.claude-code

    ];
  };

  home.packages = with pkgs; [
    texliveFull
    texlivePackages.titlesec
  ];
}
