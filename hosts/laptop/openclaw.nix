{config, pkgs, inputs, ...}:
{
  sops.secrets.openclawGW = {
    sopsFile = ../../secrets/openclaw.yaml;
  };
  sops.secrets.telegram = {
    sopsFile = ../../secrets/openclaw.yaml;
  };
  programs.openclaw = {
    enable = true;
    config = {
      gateway = {
        mode = "local";
        auth = {
          token = config.sops.secrets.openclawGW.path; # or set OPENCLAW_GATEWAY_TOKEN
        };
      };

      channels.telegram = {
        tokenFile = config.sops.secrets.telegram.path; # any file path works
        allowFrom = [ 7104033970 ];  # your Telegram user ID
      };
    };

    # Built-ins (tools + skills) shipped via nix-steipete-tools.
  };
}