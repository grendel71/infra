{config, pkgs, inputs, ...}:
{
  home.packages = with pkgs; [
    zed-editor
    nil
    nixd
  ];
}
