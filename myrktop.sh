#!/bin/bash

echo "🔥 Orange Pi 5 Plus - System Monitor 🔥"

# Device Info
device_info=$(cat /proc/device-tree/compatible 2>/dev/null | tr -d '\0' || echo "N/A")
echo "Device: $device_info"
npu_version=$(cat /sys/kernel/debug/rknpu/version 2>/dev/null || echo "N/A")
echo "Version: $npu_version"
echo "--------------------------------------"

# CPU Usage & Frequency
echo "📊 CPU Usage & Frequency:"

# Get total CPU usage
cpu_load=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}' | cut -d. -f1)
echo "Total CPU Load: ${cpu_load}%"

# Get individual core usage from /proc/stat
declare -A cpu_stats_old cpu_stats_new
while IFS= read -r line; do
    if [[ $line =~ ^cpu([0-9]+) ]]; then
        core=${BASH_REMATCH[1]}
        cpu_stats_old[$core]=$line
    fi
done < /proc/stat

sleep 0.2

while IFS= read -r line; do
    if [[ $line =~ ^cpu([0-9]+) ]]; then
        core=${BASH_REMATCH[1]}
        cpu_stats_new[$core]=$line
    fi
done < /proc/stat

# Calculate and display each core's usage
for i in {0..7}; do
    freq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null || echo 0)
    freq_mhz=$((freq/1000))

    old=(${cpu_stats_old[$i]})
    new=(${cpu_stats_new[$i]})
    old=("${old[@]:1}")
    new=("${new[@]:1}")
    
    old_sum=0
    new_sum=0
    for j in {0..9}; do
        old_sum=$((old_sum + ${old[$j]:-0}))
        new_sum=$((new_sum + ${new[$j]:-0}))
    done
    
    old_idle=${old[3]}
    new_idle=${new[3]}
    
    diff_idle=$((new_idle - old_idle))
    diff_total=$((new_sum - old_sum))
    
    if [ $diff_total -eq 0 ]; then
        usage=$cpu_load
    else
        usage=$(( 100 * (diff_total - diff_idle) / diff_total ))
    fi

    echo "Core $i: ${usage}% $freq_mhz MHz"
done
echo "--------------------------------------"

# GPU Load & Frequency
gpu_path="/sys/devices/platform/fb000000.gpu-panthor/devfreq/fb000000.gpu-panthor"
gpu_load=$(awk -F'[@ ]' '{print $1}' "$gpu_path/load" 2>/dev/null || echo "0")
gpu_freq=$(cat "$gpu_path/cur_freq" 2>/dev/null || echo "0")
echo "🎮 GPU Load: ${gpu_load}%"
echo "🎮 GPU Frequency: $((gpu_freq / 1000000)) MHz"

# NPU Load & Frequency
npu_load=$(cat /sys/kernel/debug/rknpu/load 2>/dev/null | sed -E 's/NPU load: //; s/Core[0-2]: //g; s/  +/ /g; s/,//g; s/%//g' | xargs -n3 | sed 's/ / % /g; s/$/ %/' || echo "0 % 0 % 0 %")
npu_freq=$(cat /sys/class/devfreq/fdab0000.npu/cur_freq 2>/dev/null || echo "0")
echo "🧠 NPU Load: $npu_load"
echo "🧠 NPU Frequency: $((npu_freq / 1000000)) MHz"

# RGA Load
rga_load=$(cat /sys/kernel/debug/rkrga/load 2>/dev/null | grep -oP 'load = \K[0-9]+(?=%)' | paste -sd ' ' | sed 's/$/ %/' || echo "0 0 0 %")
echo "🖼️ RGA Load: $rga_load"

echo "--------------------------------------"
# RAM & Swap Usage
echo "🖥️ RAM & Swap Usage:"
free -h | awk '/Mem:/ {print "RAM Used: " $3 " / " $2}'
free -h | awk '/Swap:/ {print "Swap Used: " $3 " / " $2}'

echo "--------------------------------------"
# Temperatures
echo "🌡️ Temperatures:"
sensors | awk '
/thermal|nvme|gpu/ {name=$1}
/temp1|Composite/ {print name ": " $2}
'
