# Anti-Detection VM Configuration for Anti-Cheat Research
**Date:** 2026-07-09  
**Target:** win10 libvirt/QEMU VM

## 1. Overview

### Purpose
Transform the existing win10 QEMU/KVM virtual machine into a stealth configuration for anti-cheat research by hiding virtualization signatures and mimicking bare-metal hardware characteristics.

### Scope
- Libvirt XML configuration modifications only
- Post-install Windows registry cleanup procedures
- Maximum stealth approach (Approach A) trading performance for detection resistance

### Use Case
Security research on anti-cheat systems (EAC, BattlEye, Vanguard, etc.) that employ VM detection techniques including CPUID checks, SMBIOS enumeration, device fingerprinting, and timing attacks.

### Limitations
- Uses emulated graphics (VGA) instead of GPU passthrough - limits effectiveness against graphics driver inspection
- Cannot fully defeat kernel-level hypervisor MSR timing checks (Vanguard's most aggressive methods)
- Performance tradeoff: removes virtio optimizations for stealth

## 2. Architecture

### Detection Vectors Addressed

| Vector | Mitigation |
|--------|-----------|
| CPUID hypervisor bit | KVM hidden feature + CPU feature masking |
| SMBIOS/DMI strings | Spoof with Lenovo ThinkPad T14 Gen 5 values |
| PCI device IDs | Replace virtio/QXL with emulated standard devices |
| Hyper-V enlightenments | Remove all paravirtualization features |
| ACPI tables | SMBIOS spoofing provides realistic firmware |
| VM-specific devices | Remove virtio-serial, memballoon, SPICE channels |
| Timing attacks | TSC native mode, HPET enabled |
| Network fingerprinting | MAC address with Intel OUI |

### Detection Vectors NOT Addressed

| Vector | Reason |
|--------|--------|
| GPU driver analysis | Emulated VGA vs real GPU - would need passthrough |
| Advanced RDTSC variance | Emulation layer adds inherent timing variance |
| Kernel MSR checks | Some hypervisor presence remains at low level |
| DMA timing analysis | Emulated devices have different latency profiles |

### Strategy
1. **Hide hypervisor layer** - KVM feature hiding, CPU masking
2. **Spoof hardware identity** - SMBIOS with realistic Lenovo values (modified serials)
3. **Replace VM devices** - Swap virtio/paravirt for emulated "real" hardware
4. **Mitigate timing** - Native TSC mode, realistic timers
5. **Clean metadata** - Remove SPICE, guest tools, VM channels

## 3. Libvirt XML Changes

### 3.1 Features Section

**Add KVM hiding:**
```xml
<features>
  <acpi/>
  <apic/>
  <kvm>
    <hidden state='on'/>
  </kvm>
  <vmport state='off'/>
</features>
```

**Remove entirely:**
- All Hyper-V enlightenments (`<hyperv mode='custom'>` block with relaxed, vapic, spinlocks, vpindex, runtime, synic, stimer, frequencies, tlbflush, ipi, evmcs, avic)

**Rationale:** Hyper-V features advertise paravirtualization. KVM hidden masks the CPUID hypervisor bit.

### 3.2 CPU Configuration

**Replace current CPU definition with:**
```xml
<cpu mode='host-passthrough' check='none' migratable='on'>
  <feature policy='disable' name='hypervisor'/>
  <topology sockets='1' dies='1' cores='4' threads='1'/>
</cpu>
```

**Changes:**
- `feature policy='disable' name='hypervisor'` - Explicitly mask hypervisor CPUID leaf
- `topology` - Define realistic quad-core layout (matches current 4 vCPU allocation)

### 3.3 Clock and Timers

**Replace current clock section with:**
```xml
<clock offset='localtime'>
  <timer name='rtc' tickpolicy='catchup'/>
  <timer name='pit' tickpolicy='delay'/>
  <timer name='hpet' present='yes'/>
  <timer name='tsc' present='yes' mode='native'/>
</clock>
```

**Changes:**
- Remove `<timer name='hypervclock'/>` - VM signature
- Add `tsc` timer with native mode - more realistic timing behavior
- Change `hpet` from `present='no'` to `present='yes'` - standard PC hardware

### 3.4 SMBIOS Spoofing

**Add to `<os>` section (after `<boot dev='hd'/>`)**:
```xml
<smbios mode='sysinfo'/>
```

**Add new `<sysinfo>` block after `<metadata>` section:**
```xml
<sysinfo type='smbios'>
  <bios>
    <entry name='vendor'>LENOVO</entry>
    <entry name='version'>N47ET28W (1.17)</entry>
    <entry name='date'>07/22/2024</entry>
  </bios>
  <system>
    <entry name='manufacturer'>LENOVO</entry>
    <entry name='product'>21MMS04F00</entry>
    <entry name='version'>ThinkPad T14 Gen 5</entry>
    <entry name='serial'>PF3XK9T2</entry>
    <entry name='uuid'>593168f2-2827-4904-8c54-3fc4b5229226</entry>
    <entry name='sku'>LENOVO_MT_21MM_BU_Think_FM_ThinkPad T14 Gen 5</entry>
    <entry name='family'>ThinkPad T14 Gen 5</entry>
  </system>
  <baseBoard>
    <entry name='manufacturer'>LENOVO</entry>
    <entry name='product'>21MMS04F00</entry>
    <entry name='version'>SDK0T76530 WIN</entry>
    <entry name='serial'>L1HF2CG05K7</entry>
  </baseBoard>
  <chassis>
    <entry name='manufacturer'>LENOVO</entry>
    <entry name='version'>None</entry>
    <entry name='serial'>PF3XK9T2</entry>
    <entry name='asset'>No Asset Information</entry>
    <entry name='sku'>LENOVO_MT_21MM_BU_Think_FM_ThinkPad T14 Gen 5</entry>
  </chassis>
</sysinfo>
```

**Values based on:** Host system (/sys/class/dmi/id/*) with modified serials/dates to avoid fingerprint collision
- BIOS version: N47ET28W (1.17) - plausible newer version
- Dates: Different from host but realistic
- Serials: Fake but follow Lenovo patterns (PF3XK9T2, L1HF2CG05K7)
- Model/product codes: Authentic ThinkPad T14 Gen 5 identifiers

### 3.5 Graphics and Display

**Replace QXL video with standard VGA:**

Current:
```xml
<video>
  <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
</video>
```

New:
```xml
<video>
  <model type='vga' vram='16384' heads='1' primary='yes'/>
</video>
```

**Replace SPICE with VNC:**

Current:
```xml
<graphics type='spice' port='5900' autoport='yes' listen='127.0.0.1'>
  <listen type='address' address='127.0.0.1'/>
  <image compression='off'/>
</graphics>
```

New:
```xml
<graphics type='vnc' port='-1' autoport='yes' listen='127.0.0.1'>
  <listen type='address' address='127.0.0.1'/>
</graphics>
```

**Rationale:** QXL is QEMU-specific. VGA is standard PC graphics. VNC has no guest-side components unlike SPICE.

### 3.6 Network Interface

**Modify MAC address to Intel OUI:**

Current:
```xml
<interface type='network'>
  <mac address='52:54:00:ff:47:52'/>
  <source network='default'/>
  <model type='e1000e'/>
</interface>
```

New:
```xml
<interface type='network'>
  <mac address='00:1b:21:3a:4f:c8'/>
  <source network='default'/>
  <model type='e1000e'/>
</interface>
```

**Rationale:** 
- `52:54:00` is QEMU's default OUI (dead giveaway)
- `00:1b:21` is Intel's OUI (matches e1000e device)
- Keep e1000e model (Intel Gigabit - realistic)

### 3.7 Device Removals

**Remove these entire device blocks:**

1. **virtio-serial controller:**
```xml
<controller type='virtio-serial' index='0'>
  ...
</controller>
```

2. **virtio memballoon:**
```xml
<memballoon model='virtio'>
  ...
</memballoon>
```

3. **SPICE channel:**
```xml
<channel type='spicevmc'>
  <target type='virtio' name='com.redhat.spice.0'/>
  ...
</channel>
```

4. **USB tablet input:**
```xml
<input type='tablet' bus='usb'>
  ...
</input>
```

5. **SPICE USB redirection devices (both):**
```xml
<redirdev bus='usb' type='spicevmc'>
  ...
</redirdev>
```

6. **Watchdog:**
```xml
<watchdog model='itco' action='reset'>
  ...
</watchdog>
```

**Rationale:** All are VM-specific devices with no bare-metal equivalent. Virtio devices are paravirtualization signatures.

### 3.8 Devices to Keep

**Storage:**
- SATA controller (realistic AHCI)
- Disk: `bus='sata'` (keep as-is)
- CD-ROM: `bus='sata'` (keep as-is)

**Audio:**
- `<sound model='ich9'/>` - Intel ICH9 chipset audio (realistic)

**Input:**
- PS/2 keyboard and mouse (standard PC devices)

**USB Controller:**
- `qemu-xhci` (realistic USB 3.0 controller)

## 4. Windows Guest Configuration

### 4.1 Installation Strategy

**Do NOT install:**
- VirtIO guest drivers (paravirtualization signature)
- QEMU guest agent (obvious VM tool)
- Spice guest tools

**Use only:**
- Windows built-in drivers for VGA, e1000e, SATA
- Standard Windows input drivers

### 4.2 Registry Modifications

After Windows installation, perform these registry edits to hide VM device names:

#### Device Manager String Cleanup

**Location:** `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum`

**Method:** Press Ctrl+F, search for each GUID, modify device description strings:

**1. Disk Drives (`4d36e967-e325-11ce-bfc1-08002be10318`):**
- Find entries with "QEMU HARDDISK" or similar
- Change `FriendlyName` to: `Samsung SSD 870 EVO 500GB`

**2. Display Adapters (`4d36e968-e325-11ce-bfc1-08002be10318`):**
- Find "Standard VGA Graphics Adapter" or "Microsoft Basic Display Adapter"
- Keep as-is (generic names are fine) OR change to common GPU name if needed

**3. CD-ROM Drives (`4d36e965-e325-11ce-bfc1-08002be10318`):**
- Find "QEMU DVD-ROM" or "QEMU CD-ROM"
- Change to: `HL-DT-ST DVDRAM GH24NSC0` (realistic ODD model)

**4. Mouse/HID Devices (`4d36e96f-e325-11ce-bfc1-08002be10318`):**
- Multiple entries for pointing devices
- Change any "QEMU" references to: `HID-compliant mouse`

#### Hide VM Tools in Programs List

**Location:** `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`

For any QEMU/VirtIO/VM-related entries:
1. Create new DWORD value: `SystemComponent`
2. Set value to: `1`
3. This hides from "Programs and Features" control panel

### 4.3 Verification Testing

**Run these commands in Windows to verify spoofing:**

```cmd
systeminfo
wmic bios get manufacturer,version,serialnumber
wmic computersystem get manufacturer,model
wmic baseboard get manufacturer,product,serialnumber
```

**Expected output:**
- Manufacturer: LENOVO
- Model: ThinkPad T14 Gen 5
- BIOS: N47ET28W (1.17)
- No mentions of "Virtual", "QEMU", "KVM"

**Advanced detection tools to test:**

1. **Pafish** (https://github.com/a0rtega/pafish)
   - Should pass most checks except advanced timing
   
2. **Al-Khaser** (https://github.com/LordNoteworthy/al-khaser)
   - May still detect some vectors (graphics driver inspection, MSR checks)
   
3. **ScoopyNG** 
   - VM detection tool - test all categories

## 5. Implementation Process

### 5.1 Pre-Implementation

1. **Backup current VM:**
   ```bash
   virsh dumpxml win10 > ~/win10-backup.xml
   cp /var/lib/libvirt/images/win10.qcow2 ~/win10-backup.qcow2
   ```

2. **Stop VM if running:**
   ```bash
   virsh shutdown win10
   # Wait for shutdown
   virsh destroy win10  # Force if needed
   ```

### 5.2 XML Editing

**Method:** Use `virsh edit win10` to modify the XML in-place

**Changes in order:**
1. Add `<sysinfo>` block after `<metadata>`
2. Add `<smbios mode='sysinfo'/>` in `<os>` section
3. Replace `<features>` section (add KVM hidden, remove Hyper-V)
4. Replace `<cpu>` section (add feature masking, topology)
5. Replace `<clock>` section (remove hypervclock, add TSC)
6. Modify `<interface>` MAC address
7. Replace `<video>` model (qxl → vga)
8. Replace `<graphics>` (spice → vnc)
9. Remove device blocks (virtio-serial, memballoon, channel, tablet, redirdev, watchdog)

### 5.3 Post-Edit Validation

**Verify XML syntax:**
```bash
virsh dumpxml win10 > /tmp/test.xml
virt-xml-validate /tmp/test.xml
```

**Start VM and test:**
```bash
virsh start win10
virsh vncdisplay win10  # Get VNC port
# Connect with VNC client (virt-viewer or similar)
```

### 5.4 Windows Guest Configuration

**After Windows boots:**
1. Verify no VirtIO drivers installed
2. Perform registry modifications (Section 4.2)
3. Run verification commands (Section 4.3)
4. Test with detection tools
5. Reboot and verify persistence

## 6. Expected Results

### What Will Pass Detection

✅ Basic CPUID hypervisor bit checks  
✅ SMBIOS/DMI firmware string enumeration  
✅ Device Manager device name inspection  
✅ Registry-based VM tool detection  
✅ Simple anti-cheat (EAC basic level)  
✅ MAC address OUI checks  
✅ WMI queries for manufacturer/model  

### What May Still Be Detected

⚠️ Advanced RDTSC timing variance analysis  
⚠️ Kernel-level hypervisor MSR presence checks (Vanguard)  
⚠️ Graphics driver deep inspection (VGA vs real GPU)  
⚠️ PCIe bus enumeration timing  
⚠️ DMA latency profiling  
⚠️ CPU cache timing side channels  

### Performance Impact

- **Graphics:** Lower performance (VGA vs QXL/virtio-gpu)
- **Disk I/O:** Slightly lower (no virtio-scsi optimizations, but SATA is acceptable)
- **Network:** Minimal impact (e1000e is well-optimized)
- **Memory:** No balloon driver (static allocation, no dynamic adjustment)
- **Overall:** 10-20% performance decrease vs fully optimized virtio stack

Acceptable tradeoff for anti-detection research.

## 7. Rollback Plan

If issues occur:

**Restore original config:**
```bash
virsh shutdown win10
virsh undefine win10
virsh define ~/win10-backup.xml
```

**Restore disk image:**
```bash
cp ~/win10-backup.qcow2 /var/lib/libvirt/images/win10.qcow2
```

## 8. Future Enhancements

**If stealth needs improvement:**

1. **GPU Passthrough** - Use VFIO to pass RTX 3070 Ti (already configured in vfio.nix)
   - Eliminates graphics detection vector entirely
   - Requires host to run on integrated graphics

2. **Kernel Patches** - Apply KVM timing mitigations
   - Patch `kvm.ko` for RDTSC offset randomization
   - MSR hiding patches for Vanguard-level detection

3. **Custom ACPI Tables** - Further firmware spoofing
   - Dump real system ACPI, inject into VM
   - Requires QEMU command-line arguments

4. **Network Card Passthrough** - Use real NIC instead of emulated
   - Eliminates e1000e emulation detection
   - Requires second NIC or USB ethernet adapter

5. **Bare-Metal Timing Profiles** - Record timing characteristics from real hardware
   - Use custom QEMU patches to replay timing patterns
   - Advanced research project
