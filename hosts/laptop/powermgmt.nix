{
  config,
  pkgs,
  inputs,
  ...
}:
{
  services.logind.settings.Login = {
    HandleLidSwitch = "sleep";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

  services = {
    thermald.enable = true;
    power-profiles-daemon.enable = false;
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "always";
        };
      };
    };
    system76-scheduler = {
      enable = true;
      useStockConfig = true;
    };
  };
  powerManagement = {
    enable = true;
    powertop.enable = false;
  };

  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # Disable USB4 CLx link power management. The X1 Carbon Gen 13 has a USB4/TB4
  # host but the TB16 dock uses TB3 (Alpine Ridge) with a TB3-era retimer in
  # the cable. The TB3 retimer mishandles USB4 CL1/CL2 link state transitions
  # that occur every time the host TB controller does PCI PM, causing the link
  # to come back degraded: control transfers work (lsusb shows devices) but
  # interrupt endpoints stall (HID becomes unresponsive). Without CLx, the
  # link stays in CL0 regardless of PCI PM, so the EC can suspend the host TB
  # controller to negotiate USB-PD (charging) without dropping USB.
  boot.extraModprobeConfig = ''
    options thunderbolt clx=N
  '';

  # Pin the full TB4->TB3 bridge chain to D0 (fully active).
  # The host-side devices (NHI, root ports, USB controller) are caught by udev
  # on add/change. The dock-side Alpine Ridge bridges are re-enumerated by the
  # kernel after boltd authorizes the dock, resetting power/control to auto.
  # A systemd service re-pins them after boltd authorization completes.
  # After a Thunderbolt disconnect/reconnect (which happens when the dock's
  # DC-DC converters ramp up for USB-PD charging, causing a brief VBUS dip that
  # drops the Alpine Ridge retimer), the kernel correctly re-enumerates all USB
  # devices but libinput/the compositor races with boltd authorization events
  # and misses the udev ADD events for the new /dev/input/eventN nodes. The
  # second unbind/rebind (usb_rebind.sh) works because it happens after boltd
  # has finished, so the compositor cleanly processes the ADD events.
  # This service automates that rebind on every TB dock re-authorization.
  systemd.services.tb16-usb-recover = {
    description = "Recover Dell TB16 HID input after Thunderbolt reconnect";
    serviceConfig = {
      Type = "oneshot";
      # Rate-limit: tolerate fast reconnect loops (e.g. during boot) but don't
      # spin endlessly if something is broken.
      StartLimitIntervalSec = 120;
      StartLimitBurst = 3;
      ExecStart = pkgs.writeShellScript "tb16-usb-recover" ''
        # Wait for USB devices to fully enumerate after TB re-authorization.
        sleep 12
        SERIAL=$(${pkgs.pciutils}/bin/lspci -Dd "1b21:1142" | awk '{ print $1 }')
        if [ -z "$SERIAL" ]; then
          echo "tb16-usb-recover: ASM1042A not found, skipping"
          exit 0
        fi
        DRIVER="/sys/bus/pci/drivers/xhci_hcd"
        echo "tb16-usb-recover: rebinding xhci on $SERIAL"
        echo -n "$SERIAL" > "$DRIVER/unbind" || true
        sleep 4
        echo -n "$SERIAL" > "$DRIVER/bind"  || true
        sleep 2
        echo 0 > "$DRIVER/$SERIAL/d3cold_allowed" || true
        echo "tb16-usb-recover: done"
      '';
    };
  };

  systemd.services.tb16-pm-pin = {
    description = "Pin Dell TB16 dock PCIe bridge chain to D0";
    after = [ "bolt.service" "sys-devices-pci0000:00-0000:00:07.0.device" ];
    wants = [ "bolt.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tb16-pm-pin" ''
        sleep 10
        for dev in /sys/bus/pci/devices/*/; do
          vendor=$(cat "$dev/vendor" 2>/dev/null)
          device=$(cat "$dev/device" 2>/dev/null)
          case "$vendor:$device" in
            0x8086:0x1578|0x1b21:0x1142)
              echo on > "$dev/power/control"
              echo 0 > "$dev/d3cold_allowed"
              echo "Pinned $(basename $dev) ($vendor:$device)"
              ;;
          esac
        done
      '';
    };
  };

  services.udev.extraRules = ''
    # Trigger HID input recovery when boltd re-authorizes the TB16 dock after
    # a Thunderbolt disconnect/reconnect. vendor=0xd4 (Dell), device=0xb054
    # (TB16 dock BME). The service waits for USB enumeration then rebinds the
    # ASM1042A xhci so libinput picks up the new /dev/input/event* nodes.
    ACTION=="change", SUBSYSTEM=="thunderbolt", ATTR{vendor}=="0xd4", ATTR{device}=="0xb054", ATTR{authorized}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start tb16-usb-recover.service"
    # Meteor Lake-P TB4 NHI #0/#1: block D3cold so the EC can runtime-suspend
    # the NHI for USB-PD (charging) negotiation without dropping the TB3 tunnel.
    # D3hot is fine (clx=N keeps the link in CL0 during D3hot); D3cold cuts all
    # power and tears the tunnel down, leaving USB devices enumerated but with
    # stalled HID interrupt rings.
    # NOTE: 0x7ec0 = TB4 USB Controller, 0x7ec2 = NHI #0, 0x7ec3 = NHI #1.
    # (0x7d0d is Platform Monitoring Technology — an unrelated device.)
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec0", ATTR{d3cold_allowed}="0"
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec2", ATTR{d3cold_allowed}="0"
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec3", ATTR{d3cold_allowed}="0"
    # Meteor Lake TB4 NHI controllers - pin active to prevent TB link drops
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec2", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec3", ATTR{power/control}="on"
    # Meteor Lake TB4 PCIe root ports
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec4", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7ec6", ATTR{power/control}="on"
    # Alpine Ridge DSL6540 Thunderbolt 3 Bridge (upstream + downstream ports)
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x1578", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x1578", ATTR{d3cold_allowed}="0"
    # ASMedia ASM1042A USB 3.0 Host Controller (inside TB16 dock)
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x1b21", ATTR{device}=="0x1142", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x1b21", ATTR{device}=="0x1142", ATTR{d3cold_allowed}="0"
    # Microchip USB5537B hubs inside TB16 dock (USB2 + USB3) - prevent hub
    # autosuspend which makes downstream HID devices unresponsive
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0424", ATTR{idProduct}=="2807", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0424", ATTR{idProduct}=="5807", ATTR{power/control}="on"
    # Keychron C2 reports VID 05AC:024F (Apple Aluminium Keyboard), causing
    # hid_apple to claim it. After a Thunderbolt reconnect the apple driver
    # sends Apple-specific init control requests that time out on the Keychron,
    # leaving it bound but silent. hid-generic has no such init path.
    ACTION=="add", SUBSYSTEM=="hid", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="024f", ATTR{driver_override}="hid-generic"
  '';

  services.upower = {
    enable = true;

  };
  #powerManagement.powertop.enable = true;
}
