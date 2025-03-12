#!/bin/bash

# Function to read privileged files
read_sudo_file() {
    sudo cat "$1" 2>/dev/null || echo "N/A"
}

echo "🔥 Orange Pi 5 Plus - System Monitor 🔥"

# 🌍 Device Info
device_info=$(cat /sys/firmware/devicetree/base/compatible 2>/dev/null | tr -d '\0' || echo "N/A")
echo "Device: $device_info"
echo "--------------------------------------"

# 📊 CPU Usage & Frequency
echo "📊 CPU Usage & Frequency:"

# Get number of CPU cores dynamically
num_cores=$(nproc --all)
echo "Number of CPU cores: $num_cores"

# Capture CPU load over time for all cores
declare -a cpu_loads
declare -a prev_total
declare -a prev_idle

# Initialize arrays for all cores
for i in $(seq 0 $((num_cores-1))); do
    stats=$(grep "cpu$i " /proc/stat)
    if [ -n "$stats" ]; then
        read -r cpu user nice system idle iowait irq softirq steal guest guest_nice <<< "$stats"
        prev_total[i]=$((user + nice + system + idle + iowait + irq + softirq + steal))
        prev_idle[i]=$idle
    fi
done

sleep 1

# Calculate CPU usage for each core
total_load=0
for i in $(seq 0 $((num_cores-1))); do
    stats=$(grep "cpu$i " /proc/stat)
    if [ -n "$stats" ]; then
        read -r cpu user nice system idle iowait irq softirq steal guest guest_nice <<< "$stats"
        total=$((user + nice + system + idle + iowait + irq + softirq + steal))
        diff_total=$((total - prev_total[i]))
        diff_idle=$((idle - prev_idle[i]))
        if [ $diff_total -ne 0 ]; then
            cpu_loads[i]=$((100 * (diff_total - diff_idle) / diff_total))
            total_load=$((total_load + cpu_loads[i]))
        else
            cpu_loads[i]=0
        fi
    fi
done

# Calculate average CPU load
avg_load=$((total_load / num_cores))
echo "Average CPU Load: ${avg_load}%"

# Print individual core information
for i in $(seq 0 $((num_cores-1))); do
    freq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null || echo 0)
    printf "Core %d: %s%% %d MHz\n" "$i" "${cpu_loads[i]}" "$((freq / 1000))"
done

echo "--------------------------------------"

# 🎮 GPU Load & Frequency
gpu_path="/sys/class/devfreq/fb000000.gpu"
if [ -d "$gpu_path" ]; then
    gpu_load=$(awk -F'[@ ]' '{print $1}' "$gpu_path/load" 2>/dev/null || echo "N/A")
    gpu_freq=$(cat "$gpu_path/cur_freq" 2>/dev/null || echo "N/A")
    if [ "$gpu_freq" != "N/A" ]; then
        gpu_freq_mhz=$((gpu_freq / 1000000))
    else
        gpu_freq_mhz="N/A"
    fi
    echo "🎮 GPU Load: ${gpu_load}%"
    echo "🎮 GPU Frequency: ${gpu_freq_mhz} MHz"
else
    echo "🎮 GPU information not available"
fi

# 🖼️ RGA Load
echo -e "\n🖼️ RGA Load:"
rga_load=$(read_sudo_file "/sys/kernel/debug/rkrga/load")
if [ "$rga_load" != "N/A" ]; then
    echo "$rga_load" | grep -E "load = |scheduler"
else
    echo "RGA load information not available"
fi

# 🧠 NPU Information
echo -e "\n🧠 NPU Information:"
npu_path="/sys/class/devfreq/fdab0000.npu"
npu_debug="/sys/kernel/debug/rknpu"

# NPU Frequency from devfreq
if [ -d "$npu_path" ]; then
    npu_freq=$(cat "$npu_path/cur_freq" 2>/dev/null || echo "N/A")
    if [ "$npu_freq" != "N/A" ]; then
        npu_freq_mhz=$((npu_freq / 1000000))
        echo "NPU Frequency: ${npu_freq_mhz} MHz"
    fi
fi

# NPU Load from debug fs
npu_load=$(read_sudo_file "$npu_debug/load")
if [ "$npu_load" != "N/A" ]; then
    echo "NPU Load: $npu_load"
fi

# NPU Power from debug fs
npu_power=$(read_sudo_file "$npu_debug/power")
if [ "$npu_power" != "N/A" ]; then
    echo "NPU Power: $npu_power"
fi

echo "--------------------------------------"

# 🖥️ RAM & Swap Usage
echo "🖥️ RAM & Swap Usage:"
free -h | awk '/Mem:/ {print "RAM Used: " $3 " / " $2}'
free -h | awk '/Swap:/ {print "Swap Used: " $3 " / " $2}'

echo "--------------------------------------"

# 🌡️ Temperatures
echo "🌡️ Temperatures:"
if command -v sensors &> /dev/null; then
    sensors | awk '
    /thermal|nvme|gpu/ {name=$1}
    /temp1|Composite/ {print name ": " $2}
    '
else
    # Fallback to reading directly from thermal zones
    for thermal in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$thermal" ]; then
            temp=$(awk '{printf "%.1f°C\n", $1/1000}' "$thermal")
            zone=$(basename "$(dirname "$thermal")")
            echo "$zone: $temp"
        fi
    done
fi
