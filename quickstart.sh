#!/bin/bash

# xv6-labs-2025 Quick Start Script
# This script automates the installation and setup of xv6-labs-2025
# Verified on WSL2 environment with Ubuntu 26.04 LTS

set -e  # Exit on any error

echo "=========================================="
echo "xv6-labs-2025 Quick Start Setup"
echo "=========================================="
echo "This script will:"
echo "1. Install required dependencies"
echo "2. Clone the xv6-labs-2025 repository"
echo "3. Test the installation with make qemu"
echo ""
echo "Verified on: WSL2 with Ubuntu 26.04 LTS"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Please do not run this script as root. Use sudo for package installation only."
    exit 1
fi

# Update package lists
echo "Step 1: Updating package lists..."
sudo apt-get update

# Install required packages
echo "Step 2: Installing required packages..."
sudo apt-get install -y \
    git \
    build-essential \
    gdb-multiarch \
    qemu-system-riscv \
    gcc-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu

# Verify installations
echo "Step 3: Verifying installations..."
echo "QEMU version:"
qemu-system-riscv64 --version | head -n 1
echo ""
echo "RISC-V GCC version:"
riscv64-linux-gnu-gcc --version | head -n 1
echo ""
echo "GDB version:"
gdb-multiarch --version | head -n 1
echo ""

# Clone repository if not already present
REPO_DIR="xv6-labs-2025"
if [ -d "$REPO_DIR" ]; then
    echo "Step 4: Repository already exists. Pulling latest changes..."
    cd "$REPO_DIR"
    git pull
else
    echo "Step 4: Cloning xv6-labs-2025 repository..."
    git clone https://github.com/TVKain/xv6-labs-2025.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

echo ""
echo "Step 5: Building xv6 kernel..."
make clean
make

echo ""
echo "Step 6: Testing xv6 with QEMU (10 second timeout)..."
echo "The kernel should boot and show 'xv6 kernel is booting' message."
echo ""

# Run QEMU with timeout to test boot, capture output
timeout 10 make qemu > /tmp/xv6_test_output.txt 2>&1 || true

# Small delay to ensure QEMU has fully terminated
sleep 1

echo ""
echo "QEMU test completed (timed out after 10 seconds - this is expected)"

# Check if kernel booted successfully
if grep -q "xv6 kernel is booting" /tmp/xv6_test_output.txt; then
    echo "✓ Installation successful! Kernel booted properly."
else
    echo "⚠ Warning: Kernel may not have booted successfully."
    echo "Check the output above for errors."
fi

# Clean up
rm -f /tmp/xv6_test_output.txt

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "To run xv6 normally, use:"
echo "  cd $REPO_DIR"
echo "  make qemu"
echo ""
echo "To run with GDB debugging:"
echo "  cd $REPO_DIR"
echo "  make qemu-gdb"
echo "  # In another terminal: gdb kernel/kernel"
echo ""
echo "For more information, see the repository README"
echo "=========================================="
