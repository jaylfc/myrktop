# 🖥️ myrktop — Orange Pi 5 (RK3588) System Monitor

🔥 **myrktop** is a lightweight, real-time system monitor for **Orange Pi 5 (RK3588)** built with Python and urwid. It provides live stats for CPU, GPU, NPU, RAM, temperatures, network, disk, and SMART storage health — all in a scrollable terminal dashboard.

---

## 📥 Installation

### 1️⃣ Install Dependencies
```bash
sudo apt update && sudo apt install -y python3 python3-pip lm-sensors smartmontools nvme-cli
sudo sensors-detect --auto
pip3 install urwid
```

### 2️⃣ Download & Install myrktop
```bash
wget -O ~/myrktop.py https://raw.githubusercontent.com/mhl221135/myrktop/refs/heads/main/myrktop.py
wget -O /usr/local/bin/myrktop https://raw.githubusercontent.com/mhl221135/myrktop/refs/heads/main/myrktop
sudo chmod +x /usr/local/bin/myrktop
```

### 3️⃣ Run
```bash
myrktop
```

---

## 📊 Features

| Category | Details |
|---|---|
| **CPU** | Per-core load + frequency with ASCII progress bars |
| **GPU** | Load % + frequency with colored progress bar |
| **NPU** | Per-core load % + frequency |
| **RGA** | Rockchip RGA engine utilisation |
| **RAM & Swap** | Usage with ASCII progress bars + percentages |
| **Temperatures** | Color-coded: 🟢 <60°C  🟡 60–69°C  🔴 ≥70°C |
| **Network** | Per-interface Down/Up in Mbps |
| **Disk Usage** | All /etc/fstab mountpoints via fast `statvfs()` (no subprocess) |
| **SMART Health** | NVMe & ATA drive info — refreshed in background every 60 s |
| **Top Processes** | Top 5 CPU-consuming processes (PID, name, RSS) |

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `q` / `Q` | Quit |
| `r` / `R` | Cycle refresh rate: **0.5 s → 1 s → 2 s** |
| `h` / `H` | Toggle help overlay |
| `↑` / `↓` | Scroll dashboard |
| `PgUp` / `PgDn` | Page scroll |

---

## ⏱️ Refresh Tiers

Different data types update at different rates for optimal performance:

| Section | Interval |
|---------|----------|
| CPU load & frequency | every tick (0.5 s default) |
| RAM, Swap, Network | 1 s |
| Temperatures, Top Processes | 2 s |
| Disk usage | 5 s |
| Device info, Docker status | 5 s |
| **SMART drive health** | **60 s (background thread)** |

---

## 📌 Example Output

```
────────────────────────────────────────────────────
🔥  myrktop — System Monitor
────────────────────────────────────────────────────
Device : rockchip,rk3588s-orangepi-5rockchip,rk3588
NPU Ver: RKNPU driver: v0.9.8
Uptime : up 17 hours, 30 minutes
Docker : Running ✅
────────────────────────────────────────────────────
📊 CPU Usage & Frequency
Core  0: ████░░░░░░░░░░░░  22%  1800 MHz
Core  1: ██░░░░░░░░░░░░░░  12%  1800 MHz
Core  4: █████████░░░░░░░  55%  2352 MHz
Core  7: ████████████████  98%  2304 MHz   ← red
────────────────────────────────────────────────────
🎮 GPU  : ░░░░░░░░░░░░░░░░   0%   300 MHz
────────────────────────────────────────────────────
🧠 NPU  : 0% 0% 0%   1000 MHz
────────────────────────────────────────────────────
🖥️  RAM & Swap
RAM  : ████████░░░░░░░░  42%  2.4G / 15G
Swap : █░░░░░░░░░░░░░░░   6%  512M / 7.8G
────────────────────────────────────────────────────
🌡️  Temperatures
npu_thermal-virtual-0          30°C
gpu_thermal-virtual-0          30°C
────────────────────────────────────────────────────
🌐 Network Traffic
eth0          ↓    0.91 Mbps   ↑    0.06 Mbps
wlan0         ↓    0.10 Mbps   ↑    2.00 Mbps
────────────────────────────────────────────────────
💾 Storage Usage (/etc/fstab)
Mount Point             Total     Used     Free  Use%
/                        59.0G    7.2G    51.0G   12%
/media/ssdmount         938.0G  387.0G   504.0G  41%
────────────────────────────────────────────────────
NVMe Devices:
/dev/nvme0n1 — SPCC M.2 PCIe SSD  29°C  829H  spare:100%
ATA Devices:
/dev/sda — WDC WD20NMVW-11AV3S2  35°C  17169H  5200 rpm
────────────────────────────────────────────────────
⚡ Top Processes (by CPU time)
     PID  Name                CPU Ticks       RSS
    1234  node                    48291    256.0M
    5678  python3                 29810     98.5M
────────────────────────────────────────────────────
[q] Quit   [r] Refresh 500ms   [h] Help   ↑↓ Scroll
```

---

## 🔧 How to Contribute
Fork the repo and submit a pull request — issues and PRs welcome!

📂 **GitHub:** [https://github.com/mhl221135/myrktop](https://github.com/mhl221135/myrktop)

---

## ❓ Support
Open a GitHub issue or contact me directly.

---

## 🔗 License
Open-source under the **MIT License**.
