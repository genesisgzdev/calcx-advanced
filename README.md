# CalcX Advanced

Professional mathematical calculator with Zenity GUI interface

## Description

CalcX Advanced is a comprehensive mathematical calculator featuring:
- Graphical user interface using Zenity
- Command-line and interactive shell modes
- Scientific and trigonometric functions
- Complex number arithmetic
- Matrix operations and determinants
- Unit conversion system
- Persistent calculation history

## Requirements

- Bash 4.0+
- Python 3.6+
- Zenity
- BC calculator

## Installation
```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh
./scripts/install.sh
```

## Usage

### GUI Mode
```bash
./calcx.sh
```

### Command Line
```bash
./calcx.sh "2 + 2"
./calcx.sh "sqrt(16)"
```

### Interactive Shell
```bash
./calcx.sh --shell
```

## Project Structure
```
calcx-advanced/
├── src/                 # Source code
├── lib/                 # Function libraries
├── config/              # Configuration files
├── scripts/             # Installation scripts
├── tests/               # Test suite
├── examples/            # Usage examples
└── docs/                # Documentation
```

## Testing
```bash
cd tests
./run_tests.sh
```

## Author

Genesis GZ (genesisgzdev)
- Email: genzt.dev@pm.me
- GitHub: https://github.com/genesisgzdev

## License

MIT License - see LICENSE file for details

## Version

1.0.0
