{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    ocaml
    ocamlPackages.lsp
    ocamlPackages.ocaml-lsp
    ocamlformat_0_26_2
  ];
}