{
  config,
  pkgs,
  lib,
  ...
}:
let
  opencode-wrapped = pkgs.unstable.opencode.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/opencode \
        --prefix LD_LIBRARY_PATH : "${pkgs.stdenv.cc.cc.lib}/lib" \
        --set NODE_TLS_REJECT_UNAUTHORIZED 0
    '';
  });

  writeOpencodeAuth = pkgs.writeShellScript "write-opencode-auth" ''
    set -eu

    authFile="$HOME/.local/share/opencode/auth.json"
    mkdir -p "$(dirname "$authFile")"

    if [ -f "$authFile" ]; then
      ${lib.getExe pkgs.jq} \
        --arg llmgateway "$(cat ${config.sops.secrets.llmgateway.path})" \
        --arg openrouter "$(cat ${config.sops.secrets.openrouter.path})" \
        --arg opencode_go "$(cat ${config.sops.secrets."opencode-go".path})" \
        --arg neuralwatt "$(cat ${config.sops.secrets.neuralwatt.path})" \
        '.llmgateway = {type:"api", key:$llmgateway}
         | .openrouter = {type:"api", key:$openrouter}
         | ."opencode-go" = {type:"api", key:$opencode_go}
         | .neuralwatt = {type:"api", key:$neuralwatt}' \
        "$authFile" \
        > "$authFile.tmp"
    else
      ${lib.getExe pkgs.jq} -n \
        --arg llmgateway "$(cat ${config.sops.secrets.llmgateway.path})" \
        --arg openrouter "$(cat ${config.sops.secrets.openrouter.path})" \
        --arg opencode_go "$(cat ${config.sops.secrets."opencode-go".path})" \
        --arg neuralwatt "$(cat ${config.sops.secrets.neuralwatt.path})" \
        '{llmgateway:{type:"api",key:$llmgateway},
          openrouter:{type:"api",key:$openrouter},
          "opencode-go":{type:"api",key:$opencode_go},
          neuralwatt:{type:"api",key:$neuralwatt}}' \
        > "$authFile.tmp"
    fi

    mv "$authFile.tmp" "$authFile"
  '';

  writeOpencodeConfig = pkgs.writeShellScript "write-opencode-config" ''
    set -eu

    configFile="$HOME/.config/opencode/opencode.json"
    mkdir -p "$(dirname "$configFile")"

    ${lib.getExe pkgs.jq} -n \
      --arg obsidian_token "$(cat ${config.sops.secrets."obsidian-mcp-token".path})" \
      '{
        "$schema": "https://opencode.ai/config.json",
        "plugin": [
          "@ex-machina/opencode-anthropic-auth@1.8.0",
          "superpowers@git+https://github.com/obra/superpowers.git",
          "opencode-websearch"
        ],
        "mcp": {
          "obsidian": {
            "enabled": true,
            "type": "remote",
            "url": "https://127.0.0.1:27124/mcp/",
            "headers": {
              "Authorization": ("Bearer " + $obsidian_token)
            }
          }
        }
      }' \
      > "$configFile.tmp"

    mv "$configFile.tmp" "$configFile"
  '';
in
{
  home.packages = with pkgs; [
    bun
    opencode-wrapped
    unstable.opencode-desktop
  ];

  sops.secrets.llmgateway.sopsFile = ../../secrets/opencode.yaml;
  sops.secrets.openrouter.sopsFile = ../../secrets/opencode.yaml;
  sops.secrets."opencode-go".sopsFile = ../../secrets/opencode.yaml;
  sops.secrets.neuralwatt.sopsFile = ../../secrets/opencode.yaml;
  sops.secrets."obsidian-mcp-token".sopsFile = ../../secrets/opencode.yaml;

  systemd.user.services.opencode-auth = {
    Unit = {
      Description = "Write Opencode auth from sops secrets";
      Requires = [ "sops-nix.service" ];
      After = [ "sops-nix.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = writeOpencodeAuth;
    };

    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.opencode-config = {
    Unit = {
      Description = "Write Opencode config with MCP servers from sops secrets";
      Requires = [ "sops-nix.service" ];
      After = [ "sops-nix.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = writeOpencodeConfig;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
