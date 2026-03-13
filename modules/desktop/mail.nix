{ config, lib, pkgs, inputs, ... }:
{
  sops.secrets.gmail1 = {
    sopsFile = ../../secrets/gmail1.yaml;
  };

  accounts.email = {
    accounts.gmail1 = {
      address = "brandonctx0@gmail.com";
      imap.host = "imap.gmail.com";
      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
      primary = true;
      realName = "Brandon Lau";
      passwordCommand = "cat /run/user/1000/secrets/gmail1";
      smtp = {
        host = "smtp.gmail.com";
      };
      userName = "brandonctx0@gmail.com";

      thunderbird = {
        enable = true;
      };
    };
  };


}