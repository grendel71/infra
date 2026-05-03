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
        --prefix LD_LIBRARY_PATH : "${pkgs.stdenv.cc.cc.lib}/lib"
    '';
  });
in
{
  home.packages = with pkgs; [
    bun
    opencode-wrapped
    unstable.opencode-desktop
  ];

  sops.secrets.llmgateway = {
    sopsFile = ../../secrets/opencode.yaml;
  };

  xdg.configFile."opencode/opencode.json".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "plugin": [
        "@ex-machina/opencode-anthropic-auth@1.8.0",
        "superpowers@git+https://github.com/obra/superpowers.git"
      ]
    }
  '';

  home.activation.writeOpencodeAuth = lib.hm.dag.entryAfter [ "installPackages" "linkGeneration" ] ''
    authFile="$HOME/.local/share/opencode/auth.json"
    mkdir -p "$(dirname "$authFile")"
    # Preserve any existing provider creds (e.g. anthropic/openai) and only upsert llmgateway.
    if [ -f "$authFile" ]; then
      ${lib.getExe pkgs.jq} \
        --arg key "$(cat ${config.sops.secrets.llmgateway.path})" \
        '.llmgateway = {type:"api", key:$key}' \
        "$authFile" \
        > "$authFile.tmp"
    else
      ${lib.getExe pkgs.jq} -n \
        --arg key "$(cat ${config.sops.secrets.llmgateway.path})" \
        '{llmgateway:{type:"api",key: $key}}' \
        > "$authFile.tmp"
    fi
    mv "$authFile.tmp" "$authFile"
  '';
}
