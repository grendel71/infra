# VM Anti-Detection Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modify the win10 libvirt VM XML to hide virtualization signatures and mimic bare-metal Lenovo ThinkPad T14 Gen 5 hardware.

**Architecture:** Direct `virsh edit` modification of the existing win10 VM domain XML. A self-contained Python script applies all changes atomically by parsing the dumpxml output, applying all transformations in memory, and validating the result.

**Tech Stack:** Python 3 (xml.etree.ElementTree), virsh CLI, libvirt

**Note:** All virsh commands require sudo on this machine. The VM must be shut down before editing.

---

### Task 1: Backup the Existing VM Configuration

**Files:**
- Create: `~/win10-backup.xml` (via sudo)
- Create: `~/win10-backup.qcow2` disk image copy (optional, if disk exists)

- [ ] **Step 1: Stop the VM if running**

```bash
sudo virsh shutdown win10 2>/dev/null; sleep 5; sudo virsh destroy win10 2>/dev/null
```

Expected: VM is stopped (or already was).

- [ ] **Step 2: Dump the current XML to a backup file**

```bash
sudo virsh dumpxml win10 > /tmp/win10-backup.xml
```

Expected: File `/tmp/win10-backup.xml` created with valid XML content.

- [ ] **Step 3: Verify backup was created with expected sections**

```bash
grep -c '<domain' /tmp/win10-backup.xml
```

Expected: Returns `1` (one domain definition).

- [ ] **Step 4: Save a user-readable copy and note the current features**

```bash
cp /tmp/win10-backup.xml ~/win10-backup.xml
echo "=== Current features ===" && grep -A 20 '<features>' ~/win10-backup.xml
echo "=== Current devices ===" && grep '<controller type\|<video\|<graphics\|<interface\|<memballoon\|<channel\|<input\|<redirdev\|<watchdog' ~/win10-backup.xml
```

Expected: Shows current configuration for reference. Note what exists so removal steps are accurate.

**Checkpoint:** Backup created. Safe to proceed with modifications — rollback via `sudo virsh define ~/win10-backup.xml` is available.

---

### Task 2: Create the XML Transformation Script

**Files:**
- Create: `/tmp/apply-vm-stealth.py`

This script reads the dumped XML, applies all anti-detection transformations, validates, and writes the result. It handles the fact that we can't use `virsh edit` interactively and can't use sudo from this session.

- [ ] **Step 1: Write the Python transformation script**

```bash
cat > /tmp/apply-vm-stealth.py << 'PYEOF'
#!/usr/bin/env python3
"""
Apply anti-detection transformations to a win10 libvirt VM XML.
Reads XML from stdin, writes transformed XML to stdout.
Run as: sudo virsh dumpxml win10 | python3 apply-vm-stealth.py > /tmp/win10-stealth.xml
"""
import sys
import xml.etree.ElementTree as ET

XML_IN = sys.stdin.read()

# --- Parse ---
root = ET.fromstring(XML_IN)
ns_map = {}  # libvirt XML uses no namespace prefixes typically

def find_or_die(parent, tag, description):
    el = parent.find(tag)
    if el is None:
        print(f"ERROR: Could not find <{tag}> ({description})", file=sys.stderr)
        sys.exit(1)
    return el

def remove_if_exists(parent, tag, description):
    el = parent.find(tag)
    if el is not None:
        parent.remove(el)
        print(f"REMOVED: {description}", file=sys.stderr)
    else:
        print(f"NOT FOUND (skip): {description}", file=sys.stderr)

# ============================================================
# 1. FEATURES SECTION - Keep ACPI/APIC, add KVM hidden, remove Hyper-V
# ============================================================
features = find_or_die(root, 'features', 'features section')

# Remove Hyper-V enlightenments block
remove_if_exists(features, 'hyperv', '<hyperv> hyper-v enlightenments')

# Remove hap (hardware accelerated paging) if present
remove_if_exists(features, 'hap', '<hap> hardware accelerated paging')

# Ensure KVM hidden is set
kvm_el = features.find('kvm')
if kvm_el is None:
    kvm_el = ET.SubElement(features, 'kvm')
kvm_el.set('hidden', 'on')
print("SET: <kvm hidden='on'/>", file=sys.stderr)

# Ensure vmport is off
vmport = features.find('vmport')
if vmport is None:
    vmport = ET.SubElement(features, 'vmport')
vmport.set('state', 'off')
print("SET: <vmport state='off'/>", file=sys.stderr)

# ============================================================
# 2. CPU SECTION - Add hypervisor feature disable, set topology
# ============================================================
cpu = find_or_die(root, 'cpu', 'cpu section')

# Set mode to host-passthrough
cpu.set('mode', 'host-passthrough')
cpu.set('check', 'none')

# Remove migratable attribute if present (use 'on' for safety)
if 'migratable' in cpu.attrib:
    del cpu.attrib['migratable']

# Remove existing feature elements for 'hypervisor'
existing_features = cpu.findall("./feature[@name='hypervisor']")
for f in existing_features:
    cpu.remove(f)

# Add disable hypervisor feature
hyperv_feat = ET.SubElement(cpu, 'feature')
hyperv_feat.set('policy', 'disable')
hyperv_feat.set('name', 'hypervisor')
print("SET: <feature policy='disable' name='hypervisor'/>", file=sys.stderr)

# Remove existing topology if present
existing_topo = cpu.find('topology')
if existing_topo is not None:
    cpu.remove(existing_topo)

# Add realistic quad-core topology
topo = ET.SubElement(cpu, 'topology')
topo.set('sockets', '1')
topo.set('dies', '1')
topo.set('cores', '4')
topo.set('threads', '1')
print("SET: <topology sockets='1' dies='1' cores='4' threads='1'/>", file=sys.stderr)

# Remove Hyper-V specific CPU features
for bad_feat_name in ['vpindex', 'runtime', 'synic', 'stimer', 
                       'frequencies', 'tlbflush', 'ipi', 'evmcs', 'avic']:
    feats = cpu.findall(f"./feature[@name='{bad_feat_name}']")
    for f in feats:
        cpu.remove(f)
        print(f"REMOVED: CPU feature '{bad_feat_name}'", file=sys.stderr)

# Remove 'invtsc' feature if present (may cause timing mismatches)
invt = cpu.find("./feature[@name='invtsc']")
if invt is not None:
    cpu.remove(invt)
    print("REMOVED: CPU feature 'invtsc'", file=sys.stderr)

# ============================================================
# 3. CLOCK SECTION - Remove hypervclock, add TSC, enable HPET
# ============================================================
clock = find_or_die(root, 'clock', 'clock section')
clock.set('offset', 'localtime')

# Remove existing timers
existing_timers = clock.findall('timer')
for t in existing_timers:
    clock.remove(t)
print("REMOVED: All existing timers (rebuilding)", file=sys.stderr)

# Add RTC timer
rtc = ET.SubElement(clock, 'timer')
rtc.set('name', 'rtc')
rtc.set('tickpolicy', 'catchup')

# Add PIT timer
pit = ET.SubElement(clock, 'timer')
pit.set('name', 'pit')
pit.set('tickpolicy', 'delay')

# Add HPET timer
hpet = ET.SubElement(clock, 'timer')
hpet.set('name', 'hpet')
hpet.set('present', 'yes')

# Add TSC timer in native mode
tsc = ET.SubElement(clock, 'timer')
tsc.set('name', 'tsc')
tsc.set('present', 'yes')
tsc.set('mode', 'native')

print("SET: timers: rtc(catchup), pit(delay), hpet(yes), tsc(native)", file=sys.stderr)

# ============================================================
# 4. OS SECTION - Add SMBIOS reference
# ============================================================
os_el = find_or_die(root, 'os', 'os section')

# Remove existing smbios if present
existing_smbios = os_el.find('smbios')
if existing_smbios is not None:
    os_el.remove(existing_smbios)

# Add smbios reference
smbios_el = ET.SubElement(os_el, 'smbios')
smbios_el.set('mode', 'sysinfo')
print("SET: <smbios mode='sysinfo'/>", file=sys.stderr)

# ============================================================
# 5. SYSINFO SECTION - Add spoofed SMBIOS data
# ============================================================
# Remove existing sysinfo if present
existing_sysinfo = root.find('sysinfo')
if existing_sysinfo is not None:
    root.remove(existing_sysinfo)
    print("REMOVED: Existing <sysinfo> (rebuilding)", file=sys.stderr)

# Find position: after <metadata> if exists, otherwise after <os>
metadata_el = root.find('metadata')
if metadata_el is not None:
    insert_idx = list(root).index(metadata_el) + 1
else:
    insert_idx = list(root).index(os_el) + 1

sysinfo = ET.Element('sysinfo', type='smbios')

# BIOS entries
bios = ET.SubElement(sysinfo, 'bios')
for name, val in [
    ('vendor', 'LENOVO'),
    ('version', 'N47ET28W (1.17)'),
    ('date', '07/22/2024'),
]:
    entry = ET.SubElement(bios, 'entry', name=name)
    entry.text = val

# System entries
system = ET.SubElement(sysinfo, 'system')
for name, val in [
    ('manufacturer', 'LENOVO'),
    ('product', '21MMS04F00'),
    ('version', 'ThinkPad T14 Gen 5'),
    ('serial', 'PF3XK9T2'),
    ('uuid', '593168f2-2827-4904-8c54-3fc4b5229226'),
    ('sku', 'LENOVO_MT_21MM_BU_Think_FM_ThinkPad T14 Gen 5'),
    ('family', 'ThinkPad T14 Gen 5'),
]:
    entry = ET.SubElement(system, 'entry', name=name)
    entry.text = val

# Baseboard entries
baseboard = ET.SubElement(sysinfo, 'baseBoard')
for name, val in [
    ('manufacturer', 'LENOVO'),
    ('product', '21MMS04F00'),
    ('version', 'SDK0T76530 WIN'),
    ('serial', 'L1HF2CG05K7'),
]:
    entry = ET.SubElement(baseboard, 'entry', name=name)
    entry.text = val

# Chassis entries
chassis = ET.SubElement(sysinfo, 'chassis')
for name, val in [
    ('manufacturer', 'LENOVO'),
    ('version', 'None'),
    ('serial', 'PF3XK9T2'),
    ('asset', 'No Asset Information'),
    ('sku', 'LENOVO_MT_21MM_BU_Think_FM_ThinkPad T14 Gen 5'),
]:
    entry = ET.SubElement(chassis, 'entry', name=name)
    entry.text = val

root.insert(insert_idx, sysinfo)
print("SET: <sysinfo> with Lenovo ThinkPad T14 Gen 5 spoofed values", file=sys.stderr)

# ============================================================
# 6. DEVICES SECTION - Multiple transformations
# ============================================================
devices = find_or_die(root, 'devices', 'devices section')

# --- 6a. Remove virtio-serial controller ---
remove_if_exists(devices, "controller[@type='virtio-serial']", 'virtio-serial controller')

# --- 6b. Remove virtio memballoon ---
remove_if_exists(devices, 'memballoon', 'virtio memballoon')

# --- 6c. Remove SPICE channel ---
for ch in devices.findall("channel[@type='spicevmc']"):
    devices.remove(ch)
    print("REMOVED: SPICE channel (spicevmc)", file=sys.stderr)

# --- 6d. Remove USB tablet input ---
for inp in devices.findall("input[@type='tablet'][@bus='usb']"):
    devices.remove(inp)
    print("REMOVED: USB tablet input", file=sys.stderr)

# --- 6e. Remove SPICE USB redirection ---
for rd in devices.findall("redirdev"):
    devices.remove(rd)
    print("REMOVED: SPICE USB redirection device", file=sys.stderr)

# --- 6f. Remove watchdog ---
remove_if_exists(devices, 'watchdog', 'watchdog')

# --- 6g. Replace video device (QXL -> VGA) ---
video_el = find_or_die(devices, 'video', 'video device')
model_el = find_or_die(video_el, 'model', 'video model')
model_el.set('type', 'vga')

# Remove QXL-specific attributes
for attr in ['ram', 'vram64', 'vgamem_mb', 'max_outputs']:
    if attr in model_el.attrib:
        del model_el.attrib[attr]

# Set standard VGA vram
model_el.set('vram', '16384')
print("SET: Video model type='vga' vram='16384'", file=sys.stderr)

# --- 6h. Replace SPICE graphics with VNC ---
existing_graphics = devices.find('graphics')
if existing_graphics is not None:
    devices.remove(existing_graphics)
    print("REMOVED: Existing <graphics> (rebuilding)", file=sys.stderr)

graphics = ET.SubElement(devices, 'graphics')
graphics.set('type', 'vnc')
graphics.set('port', '-1')
graphics.set('autoport', 'yes')
graphics.set('listen', '127.0.0.1')
listen_el = ET.SubElement(graphics, 'listen')
listen_el.set('type', 'address')
listen_el.set('address', '127.0.0.1')
print("SET: <graphics type='vnc'> with VNC on 127.0.0.1 autoport", file=sys.stderr)

# --- 6i. Modify MAC address to Intel OUI ---
interface_el = find_or_die(devices, 'interface', 'network interface')
mac_el = find_or_die(interface_el, 'mac', 'MAC address')
old_mac = mac_el.get('address', 'unknown')
mac_el.set('address', '00:1b:21:3a:4f:c8')
print(f"SET: MAC address {old_mac} -> 00:1b:21:3a:4f:c8 (Intel OUI)", file=sys.stderr)

# ============================================================
# 7. REMOVE <metadata> section if present (SPICE/Guest Agent data)
# ============================================================
remove_if_exists(root, 'metadata', '<metadata> (guest agent / VM tool data)')

# ============================================================
# 8. FINALIZE - Pretty-print result
# ============================================================
ET.indent(root, space='  ')
output = ET.tostring(root, encoding='unicode')

# Add XML declaration
print('<?xml version="1.0" encoding="UTF-8"?>')
print(output)

print("\n=== TRANSFORMATION COMPLETE ===", file=sys.stderr)
PYEOF
chmod +x /tmp/apply-vm-stealth.py
```

Expected: Script created at `/tmp/apply-vm-stealth.py` (executable).

- [ ] **Step 2: Test script syntax**

```bash
python3 -c "import py_compile; py_compile.compile('/tmp/apply-vm-stealth.py', doraise=True)" && echo "SYNTAX OK"
```

Expected: `SYNTAX OK`

**Checkpoint:** Transformation script ready. Next: apply to the actual VM XML.

---

### Task 3: Apply Transformations and Create the New VM XML

**Files:**
- Read: `/tmp/win10-backup.xml`
- Create: `/tmp/win10-stealth.xml`

- [ ] **Step 1: Apply the transformation script to the backup XML**

```bash
sudo python3 /tmp/apply-vm-stealth.py < /tmp/win10-backup.xml > /tmp/win10-stealth.xml 2>/tmp/win10-stealth.log
```

Expected: No ERROR lines in the log. Check with `grep "ERROR" /tmp/win10-stealth.log` — should return nothing.

- [ ] **Step 2: Check the transformation log**

```bash
cat /tmp/win10-stealth.log
```

Expected: Shows all SET and REMOVED operations. Any "NOT FOUND (skip)" lines are acceptable — they mean the original XML didn't have that element.

- [ ] **Step 3: Verify key changes in the output XML**

```bash
echo "=== KVM hidden ===" && grep 'kvm hidden' /tmp/win10-stealth.xml
echo "=== Disable hypervisor ===" && grep 'disable.*hypervisor' /tmp/win10-stealth.xml
echo "=== SMBIOS ===" && grep -c 'ThinkPad T14' /tmp/win10-stealth.xml
echo "=== VGA (not QXL) ===" && grep 'model type=.vga' /tmp/win10-stealth.xml
echo "=== VNC (not SPICE) ===" && grep 'graphics type=.vnc' /tmp/win10-stealth.xml
echo "=== Intel MAC ===" && grep '00:1b:21' /tmp/win10-stealth.xml
echo "=== No virtio-serial ===" && grep -c 'virtio-serial' /tmp/win10-stealth.xml
echo "=== No memballoon ===" && grep -c 'memballoon' /tmp/win10-stealth.xml
echo "=== No spicevmc ===" && grep -c 'spicevmc' /tmp/win10-stealth.xml
echo "=== TSC native ===" && grep 'tsc.*native' /tmp/win10-stealth.xml
echo "=== HPET ===" && grep 'hpet.*present.*yes' /tmp/win10-stealth.xml
```

Expected output:
```
=== KVM hidden ===
  <kvm hidden="on"/>
=== Disable hypervisor ===
  <feature policy="disable" name="hypervisor"/>
=== SMBIOS ===
3
=== VGA (not QXL) ===
  <model type="vga" vram="16384" heads="1" primary="yes"/>
=== VNC (not SPICE) ===
  <graphics type="vnc" port="-1" autoport="yes" listen="127.0.0.1">
=== Intel MAC ===
  <mac address="00:1b:21:3a:4f:c8"/>
=== No virtio-serial ===
0
=== No memballoon ===
0
=== No spicevmc ===
0
=== TSC native ===
  <timer name="tsc" present="yes" mode="native"/>
=== HPET ===
  <timer name="hpet" present="yes"/>
```

**Checkpoint:** Stealth XML generated and verified. All expected transforms applied, all VM signatures removed.

---

### Task 4: Validate XML Syntax

**Files:**
- Read: `/tmp/win10-stealth.xml`

- [ ] **Step 1: Validate with xmllint (basic XML well-formedness)**

```bash
xmllint --noout /tmp/win10-stealth.xml && echo "XML VALID"
```

Expected: `XML VALID` (no errors).

- [ ] **Step 2: Validate with virt-xml-validate (libvirt domain schema)**

```bash
sudo virt-xml-validate /tmp/win10-stealth.xml domain 2>&1
```

Expected: Either `valid` output, or if the tool isn't available, skip this step.

- [ ] **Step 3: Run libvirt dry-run define**

```bash
sudo virsh define /tmp/win10-stealth.xml 2>&1
```

Expected: No errors. If the VM is already defined, use `sudo virsh define /tmp/win10-backup.xml` to restore first, then re-define with stealth XML.

Note: If `virsh define` fails because "domain 'win10' already exists", do:
```bash
sudo virsh undefine win10 && sudo virsh define /tmp/win10-stealth.xml
```

**Checkpoint:** XML validates successfully. VM config is clean and ready to start.

---

### Task 5: Start the VM and Test

**Files:**
- None (runtime operation)

- [ ] **Step 1: Start the VM**

```bash
sudo virsh start win10
```

Expected: Domain win10 started.

- [ ] **Step 2: Wait for boot and get VNC display port**

```bash
sleep 30 && sudo virsh vncdisplay win10
```

Expected: Shows VNC port like `127.0.0.1:0` or similar. If the port is `-1`, the VM may need more time — wait and retry.

- [ ] **Step 3: Quick connectivity test (VNC probe)**

```bash
vnc_port=$(sudo virsh vncdisplay win10 2>/dev/null)
echo "VNC is on port: $vnc_port"
```

Expected: Valid VNC port shown.

- [ ] **Step 4: Commit the plan and transformed XML references**

```bash
cp /tmp/win10-stealth.xml ~/win10-stealth-final.xml
```

**Checkpoint:** VM is running with anti-detection configuration. Guest-side Windows registry changes still needed (see spec Section 4).

---

### Task 6: Commit All Artifacts

**Files:**
- Add: `docs/superpowers/plans/2026-07-09-vm-anti-detection.md`

- [ ] **Step 1: Force-add and commit the plan**

```bash
git -C /home/blau/infra add -f docs/superpowers/plans/2026-07-09-vm-anti-detection.md && git -C /home/blau/infra commit -m "Add VM anti-detection implementation plan"
```

Expected: Commit created successfully.

**Checkpoint:** Plan committed. All XML modifications complete. Next: manual Windows guest configuration.

---
