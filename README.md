# myrktop - Orange Pi 5 Plus System Monitor

A system monitoring tool optimized for the Orange Pi 5 Plus, showing CPU, GPU, NPU, RGA, memory usage and temperatures.

## Features

- CPU monitoring (8 cores)
    - CPU usage per core
    - CPU frequency per core
    - Total CPU load
- GPU monitoring
    - GPU load
    - GPU frequency
- NPU monitoring
    - 3 core usage
    - NPU frequency
- RGA monitoring
    - Load for 2x RGA3 and 1x RGA2
- Memory monitoring
    - RAM usage
    - Swap usage
- Temperature monitoring
    - CPU cores
    - GPU
    - NPU
    - Board sensors

## Installation

```bash
# Clone the repository
git clone https://github.com/jaylfc/myrktop.git
cd myrktop

# Install the monitor
sudo ./install.sh
```

The install script will:
1. Install required dependencies (lm-sensors)
2. Set up the monitoring scripts
3. Configure temperature sensors
4. Create an easy-to-use command 'rktop'

## Usage

After installation, simply run:
```bash
sudo rktop
```

Press Ctrl+C to exit the monitor.

## Hardware Support

This fork is specifically optimized for the Orange Pi 5 Plus with:
- RK3588 SoC
- Mali-G610 MC4 GPU
- RKNPU2 v2.0.0
- RGA3/2 2D graphics accelerator

## Original Project

This is a fork of [myrktop](https://github.com/mhl221135/myrktop) optimized for the Orange Pi 5 Plus.

## License

This project is licensed under the terms of the original myrktop project.
