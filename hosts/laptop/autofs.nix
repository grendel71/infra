{ pkgs, ... }:
let
  gamesDrive = "/home/blau/games";

  # External USB/Thunderbolt drive (ST2000LM007, WDZ795TL) holding the
  # games library. Identified by filesystem UUID rather than /dev/sda1
  # since device names depend on enumeration/plug order and are not
  # stable across hotplug events; the UUID is stable regardless of
  # which bus/port the drive is plugged into.
  gamesDeviceById = "/dev/disk/by-uuid/6f164541-101a-40f3-b8d6-1d11e77fdfd6";

  # Direct-mount map for the games drive. Kept in the Nix store (via
  # writeText) instead of environment.etc so the path and its contents
  # live in one place with no risk of the two drifting out of sync.
  gamesMap = pkgs.writeText "auto.games" ''
    ${gamesDrive} -fstype=auto,rw,nosuid,nodev :${gamesDeviceById}
  '';
in
{
  services.autofs.enable = true;
  services.autofs.autoMaster = ''
    /- ${gamesMap} --timeout=60
  '';

  # autofs does not pre-create mount points for direct maps, so make
  # sure the directory exists (and is owned by blau) before it's used.
  systemd.tmpfiles.rules = [
    "d ${gamesDrive} 0755 blau users - -"
  ];
}
