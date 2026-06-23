{
  config,
  pkgs,
  inputs,
  ...
}:
{
  sops.secrets.wifi-psk.sopsFile = ../../secrets/secret.yaml;

  sops.secrets.tailscale = {
    sopsFile = ../../secrets/secret.yaml;
    path = "/run/secrets/tailscale.key";
  };
  services.tailscale = {
    enable = true;
    authKeyFile = "/run/secrets/tailscale.key";
  };
}
