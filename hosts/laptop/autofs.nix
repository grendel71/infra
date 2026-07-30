{ ... }:
let
  gamesDrive = "/home/blau/games";

  # External USB/Thunderbolt drive (ST2000LM007, WDZ795TL) holding the
  # games library. Identified by filesystem UUID rather than /dev/sda1
  # since device names depend on enumeration/plug order and are not
  # stable across hotplug events; the UUID is stable regardless of
  # which bus/port the drive is plugged into.
  gamesDeviceById = "/dev/disk/by-uuid/6f164541-101a-40f3-b8d6-1d11e77fdfd6";
in
{
  # NOTE: this used to be implemented with classic autofs (services.autofs),
  # but autofs is a userspace daemon with no awareness of udev add/remove
  # events. When this drive is unplugged while mounted, autofs leaves the
  # dead mount stacked on the mountpoint and never re-triggers, so the
  # directory gets stuck returning "Input/output error" until manually
  # unmounted -- it can't recover from unplug/replug.
  #
  # systemd's native automount (via x-systemd.automount) is tied directly
  # to the udev .device unit for this UUID: the mount activates on first
  # access after the drive appears, and is cleanly torn down when the
  # drive is removed, so subsequent replugs work without intervention.
  fileSystems.${gamesDrive} = {
    device = gamesDeviceById;
    fsType = "ext4";
    options = [
      "rw"
      "nosuid"
      "nodev"
      "nofail" # don't block boot if the drive isn't plugged in
      "x-systemd.automount" # mount on first access, not at boot
      "x-systemd.idle-timeout=60" # unmount after 60s of inactivity
      "x-systemd.device-timeout=5" # don't wait long if drive is absent
    ];
  };
}
