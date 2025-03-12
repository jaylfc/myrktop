#!/bin/bash

# Check if run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

echo "Installing real-time system monitor for Orange Pi 5 Plus..."

# Install dependencies
apt-get update
apt-get install -y lm-sensors

# Create directories
install_dir="/usr/local/bin"
mkdir -p "$install_dir"

# Create wrapper script
cat > "$install_dir/rktop" << 'EOF'
#!/bin/bash
# Use watch with increased resolution (-n 0.5) and title (-t)
watch -n 1 /usr/local/bin/myrktop
EOF

# Create main monitoring script
cat > "$install_dir/myrktop" << 'EOF'
#!/bin/bash
echo "🔥 Orange Pi 5 Plus - System Monitor 🔥"
device_info=$(cat /proc/device-tree/compatible 2>/dev/null | tr -d '\0' || echo "N/A")
echo "Device: $device_info"
npu_version=$(cat /sys/kernel/debug/rknpu/version 2>/dev/null || echo "N/A")
echo "Version: $npu_version"
echo "--------------------------------------"
echo "📊 CPU Usage & Frequency:"
cpu_load=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{printf "%d", 100 - $1}')
echo "Total CPU Load: ${cpu_load}%"

# CPU cores info
for i in {0..7}; do
    freq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null || echo 0)
    freq_mhz=$((freq/1000))
    echo "Core $i: ${cpu_load}% $freq_mhz MHz"
done
echo "--------------------------------------"

# GPU info
gpu_path="/sys/devices/platform/fb000000.gpu-panthor/devfreq/fb000000.gpu-panthor"
gpu_load=$(awk -F'[@ ]' '{print $1}' "$gpu_path/load" 2>/dev/null || echo "0")
gpu_freq=$(cat "$gpu_path/cur_freq" 2>/dev/null || echo "0")
echo "🎮 GPU Load: ${gpu_load}%"
echo "🎮 GPU Frequency: $((gpu_freq / 1000000)) MHz"

# NPU info
npu_load=$(cat /sys/kernel/debug/rknpu/load 2>/dev/null | sed -E 's/NPU load: //; s/Core[0-2]: //g; s/  +/ /g; s/,//g; s/%//g' | xargs -n3 | sed 's/ / % /g; s/$/ %/' || echo "0 % 0 % 0 %")
npu_freq=$(cat /sys/class/devfreq/fdab0000.npu/cur_freq 2>/dev/null || echo "0")
echo "🧠 NPU Load: $npu_load"
echo "🧠 NPU Frequency: $((npu_freq / 1000000)) MHz"

# RGA info
rga_load=$(cat /sys/kernel/debug/rkrga/load 2>/dev/null | grep -oP 'load = \K[0-9]+(?=%)' | paste -sd ' ' | sed 's/$/ %/' || echo "0 0 0 %")
echo "🖼️  RGA Load: $rga_load"
echo "--------------------------------------"
echo "🖥️  RAM & Swap Usage:"
free -h | awk '/Mem:/ {print "RAM Used: " $3 " / " $2}'
free -h | awk '/Swap:/ {print "Swap Used: " $3 " / " $2}'
echo "--------------------------------------"
echo "🌡️  Temperatures:"
sensors | awk '
/thermal|nvme|gpu/ {name=$1}
/temp1|Composite/ {printf "%s: %s\n", name, $2}
'
EOF

chmod +x "$install_dir/myrktop" "$install_dir/rktop"

# Run sensors-detect if needed
if ! sensors > /dev/null 2>&1; then
    echo "Running sensors-detect..."
    sensors-detect --auto
    service kmod start
fi

echo "Installation complete!"
echo "You can now run 'sudo rktop' to start real-time monitoring"
echo "Press Ctrl+C to exit the monitoring"
