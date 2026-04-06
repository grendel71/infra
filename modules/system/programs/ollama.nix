{
  config,
  pkgs,
  inputs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  environment.systemPackages = with pkgs-unstable; [
    zeroclaw
  ];
  services.ollama = {
    enable = true;
    loadModels = [
      "llama3.2:3b"
      "deepseek-r1:1.5b"
    ];
    package = pkgs-unstable.ollama-cuda;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
}
