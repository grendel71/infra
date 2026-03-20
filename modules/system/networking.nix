{config, pkgs, inputs, ...}:
{
  sops.secrets.wifi-psk.sopsFile = ../../secrets/secret.yaml;

  networking.wireless.networks = {
    Stevens-IoT = {
      psk = config.sops.secrets.wifi-psk.path;
    };
  };

  sops.secrets.tailscale = {
    sopsFile = ../../secrets/secret.yaml;
    path = "/run/secrets/tailscale.key";
  };
  services.tailscale = {
    enable = true; 
    authKeyFile = "/run/secrets/tailscale.key";
  };
}