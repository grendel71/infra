{ inputs, config, mysecrets, ...}:
let
  secretspath = builtins.toString mysecrets;
in

{
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      dade_passwd = {
        neededForUsers = true;
      };
    };
  };

}