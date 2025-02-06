# Barcode Reader

A Ruby application for reading barcodes from PDF files. The application converts PDF pages to images, enhances them for better barcode detection, and extracts barcode data.

## System Requirements

### Ruby Version
* Ruby 2.6.6 or higher

### System Dependencies
Only `zbar-tools` needs to be installed as a system package. ImageMagick is handled through the `mini_magick` gem.

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install zbar-tools
```

#### Linux (RHEL/CentOS/Fedora)
```bash
sudo dnf install zbar    # Use 'yum' instead of 'dnf' for older versions
```

#### macOS
```bash
brew install zbar

# If you don't have Homebrew installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Ruby Dependencies

1. First, install bundler if you haven't:
```bash
gem install bundler
```

2. Install required gems:
```bash
bundle install
```

Key gems used:
* `pdf-reader` - For reading and processing PDF files
* `mini_magick` - For image processing and enhancement
* Standard library: `tempfile`, `fileutils`

## Usage

### Basic Usage
To scan a PDF file for barcodes:
```bash
cd test_files
bundle exec ruby barcode_reader.rb path/to/your/file.pdf
```

### Process Flow
1. PDF Processing:
   - Reads PDF using `pdf-reader`
   - Processes first two pages only
   - Converts pages to high-resolution PNG (600 DPI)

2. Image Enhancement (using `mini_magick`):
   - Converts to grayscale
   - Auto-levels and normalizes
   - Enhances contrast
   - Applies sharpening

3. Barcode Detection:
   - Uses `zbarimg` command-line tool
   - Extracts barcode data
   - Parses into CRN and Amount

### Output Format
The script outputs:
1. Raw barcode data (e.g., `*29581200051216188000014453`)
2. Parsed data:
   - Customer Reference Number (CRN)
   - Payment Amount (formatted as currency)

### Troubleshooting

#### PDF Processing Issues
If you encounter PDF processing issues:
1. Ensure PDF is not password-protected
2. Check PDF is not corrupted
3. Try with a different PDF to isolate the issue

#### Barcode Detection Issues
If barcode is not being detected:
1. Ensure PDF quality is good
2. Check if barcode is visible and not distorted
3. Try adjusting image enhancement parameters in the code

#### System Dependencies
If you get command not found errors:
1. Verify `zbar-tools` is installed: `which zbarimg`
2. Check system PATH includes the necessary directories
3. Try reinstalling the package

