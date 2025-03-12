# myrktop - Orange Pi 5 Plus System Monitor

A system monitoring tool specifically optimized for the Orange Pi 5 Plus, forked from the original myrktop project.

## Features

- CPU usage and frequency monitoring for all 8 cores (4x Cortex-A76 & 4x Cortex-A55)
- GPU (Mali-G610 MC4) load and frequency monitoring
- NPU load monitoring for all 3 cores
- RGA (2D graphics accelerator) load monitoring
- RAM and Swap usage tracking
- Temperature monitoring for various system components
- Device information display

## Requirements

- Orange Pi 5 Plus running Linux
- `sudo` access (for RGA and NPU monitoring)
- Basic system utilities (`free`, `sensors`)

## Installation

```bash
git clone https://github.com/yourusername/myrktop.git
cd myrktop
chmod +x myrktop_modified.sh
```

## Usage

For basic monitoring:
```bash
./myrktop_modified.sh
```

For full monitoring (including RGA and NPU):
```bash
sudo ./myrktop_modified.sh
```

## Features Specific to Orange Pi 5 Plus

- Optimized paths for RK3588 hardware
- Support for triple-core NPU monitoring
- RGA2/RGA3 load monitoring
- Correct thermal zone mapping
- Dynamic CPU core detection and monitoring

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the same terms as the original myrktop project.

## Acknowledgments

- Original myrktop project by mhl221135
- Orange Pi 5 Plus optimization contributors
