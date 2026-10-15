{
  config,
  pkgs,
  inputs,
  ...
}:
{
  sops.secrets.wifi-psk.sopsFile = ../../secrets/secret.yaml;

  services.tailscale.enable = true;
}
