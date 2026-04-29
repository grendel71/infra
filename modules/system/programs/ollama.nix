{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.unstable.zeroclaw
  ];
  services.ollama = {
    enable = true;
    loadModels = [
      "llama3.2:3b"
      "deepseek-r1:1.5b"
    ];
    package = pkgs.unstable.ollama-cuda;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "64000";
    };
  };
}
