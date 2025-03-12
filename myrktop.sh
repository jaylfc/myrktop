#!/bin/bash

echo "🔥 Orange Pi 5 - System Monitor 🔥"

# 🌍 Device Info
device_info=$(cat /sys/firmware/devicetree/base/compatible 2>/dev/null | tr -d '\0' || echo "N/A")
echo "Device: $device_info"
npu_version=$(cat /sys/kernel/debug/rknpu/version 2>/dev/null || echo "N/A")
echo "Version: $npu_version"
echo "--------------------------------------"

# 📊 CPU Usage & Frequency
echo "📊 CPU Usage & Frequency:"

# Capture CPU load over time for all cores
cpu_loads=()
prev_total=()
prev_idle=()

for i in {0..7}; do
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    prev_total[i]=$((user + nice + system + idle + iowait + irq + softirq + steal))
    prev_idle[i]=$idle
done

sleep 1

for i in {0..7}; do
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    diff_total=$((total - prev_total[i]))
    diff_idle=$((idle - prev_idle[i]))
    if [ $diff_total -ne 0 ]; then
        cpu_loads[i]=$((100 * (diff_total - diff_idle) / diff_total))
    else
        cpu_loads[i]=0
    fi
done

# Print CPU Load Per Core
total_load=$(awk "BEGIN {sum=0; for(i=0;i<8;i++) sum+=${cpu_loads[i]}; print sum/8}")
echo "Total CPU Load: ${total_load}%"

for i in {0..7}; do
    freq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null || echo 0)
    printf "Core %d: %s%% %d MHz\n" "$i" "${cpu_loads[i]}" "$((freq / 1000))"
done

echo "--------------------------------------"

# 🎮 GPU Load & Frequency
gpu_load=$(awk -F'[@ ]' '{print $1}' /sys/class/devfreq/fb000000.gpu/load 2>/dev/null || echo "N/A")
gpu_freq=$(cat /sys/class/devfreq/fb000000.gpu/cur_freq 2>/dev/null || echo "N/A")
echo "🎮 GPU Load: ${gpu_load}%"
echo "🎮 GPU Frequency: $((gpu_freq / 1000000)) MHz"

# 🧠 NPU Load & Frequency (Fixed Formatting)
npu_load=$(cat /sys/kernel/debug/rknpu/load 2>/dev/null | sed -E 's/NPU load: //; s/Core[0-2]: //g; s/  +/ /g; s/,//g;' | xargs || echo "N/A")
npu_freq=$(cat /sys/class/devfreq/fdab0000.npu/cur_freq 2>/dev/null || echo "N/A")
echo "🧠 NPU Load: ${npu_load}"
echo "🧠 NPU Frequency: $((npu_freq / 1000000)) MHz"

# 🖼️ RGA Load
rga_load=$(cat /sys/kernel/debug/rkrga/load 2>/dev/null || echo "N/A")
rga_values=$(echo "$rga_load" | grep -oP 'load = \K[0-9]+%' | head -n 3 | tr '\n' ' ')
echo "🖼️  RGA Load: $rga_values"

echo "--------------------------------------"
# 🖥️ RAM & Swap Usage
echo "🖥️  RAM & Swap Usage:"
free -h | awk "/Mem:/ {print \"RAM Used: \" \$3 \" / \" \$2}"
free -h | awk "/Swap:/ {print \"Swap Used: \" \$3 \" / \" \$2}"

echo "--------------------------------------"
# 🌡️ Temperatures
echo "🌡️  Temperatures:"
sensors | awk '
/thermal|nvme|gpu/ {name=$1}
/temp1|Composite/ {print name ": " $2}
'
