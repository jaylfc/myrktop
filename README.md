# myrktop - System Monitor with Orange Pi 5 Plus Support

A system monitoring tool with specialized support for the Orange Pi 5 Plus, forked from the original myrktop project.

## Features

- CPU usage and frequency monitoring
    - Orange Pi 5 Plus: All 8 cores (4x Cortex-A76 & 4x Cortex-A55)
    - Other platforms: Automatic core detection
- GPU monitoring
    - Orange Pi 5 Plus: Mali-G610 MC4 load and frequency
    - Other platforms: Basic GPU stats where available
- Memory monitoring
    - RAM usage and statistics
    - Swap usage tracking
- Temperature monitoring for various system components
- Device information display

### Orange Pi 5 Plus Specific Features

When running on an Orange Pi 5 Plus, additional features are automatically enabled:
- NPU (Neural Processing Unit) monitoring for all 3 cores
- RGA (2D Graphics Accelerator) load monitoring for RGA2/RGA3
- Optimized thermal zone mapping for accurate temperature readings
- Specialized paths for RK3588 hardware components
- Dynamic CPU core detection and monitoring

## Requirements

### General Requirements
- Linux-based operating system
- Basic system utilities (`free`, `sensors`)

### Orange Pi 5 Plus Additional Requirements
- `sudo` access (required for RGA and NPU monitoring)
- RK3588 specific tools (usually pre-installed)

## Installation

```bash
git clone https://github.com/jaylfc/myrktop.git
cd myrktop
chmod +x myrktop.sh
```

## Usage

For basic monitoring:
```bash
./myrktop.sh
```

For full monitoring on Orange Pi 5 Plus (including RGA and NPU):
```bash
sudo ./myrktop.sh
```

The script automatically detects if it's running on an Orange Pi 5 Plus and enables the appropriate features.

## Contributing

Feel free to submit issues and enhancement requests! Pull requests are welcome.

## License

This project is licensed under the same terms as the original myrktop project.

## Acknowledgments

- Original myrktop project by mhl221135
- Orange Pi 5 Plus optimization contributors
