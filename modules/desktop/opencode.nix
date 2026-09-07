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
        --set NODE_TLS_REJECT_UNAUTHORIZED 0 \
        --run 'export DEEPSEEK_API_KEY=$(cat ${config.sops.secrets.deepseek.path} 2>/dev/null || echo "")'
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

  openCodeConfigJson = pkgs.writeText "opencode-config-base.json" (
    builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugin = [
        "@ex-machina/opencode-anthropic-auth@1.8.1"
        "superpowers@git+https://github.com/obra/superpowers.git"
        "opencode-websearch"
      ];
      provider = {
        deepseek = {
          name = "DeepSeek";
          api = "openai-compatible";
          env = [ "DEEPSEEK_API_KEY" ];
          baseURL = "https://api.deepseek.com";
        };
      };
      default_agent = "plan";
      small_model = "opencode-go/deepseek-v4-pro";
      agent = {
        plan = {
          model = "opencode-go/glm-5.2";
          mode = "primary";
          description = "Orchestrator: writes plans, dispatches implementation, escalates on failure";
          prompt = ''
            You are an orchestrator for software engineering tasks. Your responsibilities:

            1. PLAN: Use the writing-plans skill to create detailed implementation plans.
            2. DISPATCH: Dispatch each independent plan step to the "build" agent (DeepSeek V4)
               via the Task tool. Run independent steps in parallel when possible.
            3. EVALUATE: When a build agent returns, assess the result. Look for:
               - Errors, tool failures, or incomplete work
               - "[ESCALATE: <reason>]" markers
               - Unsatisfactory or low-quality output
            4. ESCALATE: On failure, re-dispatch the same task to "claude-build" (Claude Sonnet).
            5. PRESENT: Show final results to the user with a clear summary.

            Always prefer dispatching to "build" first (cheap/fast). Only use "claude-build"
            when DeepSeek clearly cannot complete the task.
          '';
        };
        build = {
          model = "opencode-go/deepseek-v4-pro";
          mode = "all";
          description = "Implementation agent on DeepSeek V4";
          prompt = ''
            You are an implementation agent. Follow the plan you are given exactly.
            - Complete the task to the best of your ability.
            - If you encounter a problem you cannot solve after reasonable attempts,
              emit [ESCALATE: <brief reason>] and return control to the orchestrator.
            - Mark your work as complete explicitly.
            - Do not over-explain -- the orchestrator will review and present results.
          '';
          permission = {
            task = "allow";
          };
        };
        "claude-build" = {
          model = "anthropic/claude-sonnet-4-5";
          mode = "subagent";
          hidden = true;
          description = "Escalation subagent: takes over when DeepSeek fails";
          prompt = ''
            You are an escalation implementation agent. You are invoked when the primary
            implementation agent (DeepSeek) was unable to complete a task.
            - Pick up where the previous agent left off.
            - You may dispatch parallel subtasks to "build" agents for efficiency.
            - Complete the task thoroughly and return results to the orchestrator.
          '';
          permission = {
            task = "allow";
          };
        };
      };
    }
  );

  writeOpencodeConfig = pkgs.writeShellScript "write-opencode-config" ''
    set -eu

    configFile="$HOME/.config/opencode/opencode.json"
    mkdir -p "$(dirname "$configFile")"

    token=$(cat ${config.sops.secrets."obsidian-mcp-token".path})

    ${lib.getExe pkgs.jq} -n \
      --slurpfile base ${openCodeConfigJson} \
      --arg obsidian_token "$token" \
      '$base[0] |
       .mcp.obsidian = {
         enabled: true,
         type: "remote",
         url: "https://127.0.0.1:27124/mcp/",
         headers: {Authorization: ("Bearer " + $obsidian_token)}
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
  sops.secrets.deepseek.sopsFile = ../../secrets/opencode.yaml;

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
