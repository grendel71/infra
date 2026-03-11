{ config, lib, pkgs, inputs, ... }:
{
  sops.secrets.gmail1 = {
    sopsFile = ../../secrets/gmail1.yaml;
  };

  


}