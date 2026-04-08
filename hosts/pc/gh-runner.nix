{config, pkgs, ...}:
{
    sops.secrets.runner_token.sopsFile = ../../secrets/gh.yaml;

    # GitHub Actions Runner
    services.github-runners = {
        nix-builder = {
        enable = true;
        
        # Your repo or org URL
        url = "https://github.com/grendel71/infra";
        
        # Token file — never put the token directly in the config
        tokenFile = config.sops.runner_token.path;
        
        # Labels used in runs-on: [self-hosted, nix-builder]
        extraLabels = [ "nix-builder" "nixos" ];
        
        # Extra packages available to the runner
        extraPackages = with pkgs; [
            nix
            git
            cachix      # if using cachix
            attic-client  # if using attic
        ];

        # Extra nix config for the runner
        extraEnvironment = {
            NIX_CONFIG = "experimental-features = nix-command flakes";
        };
        };
    };

    # Allow the runner to use nix
    nix.settings = {
        trusted-users = [ "github-runner-nix-builder" ];
        experimental-features = [ "nix-command" "flakes" ];
    };
}