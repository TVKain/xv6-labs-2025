#!/bin/bash

# xv6-labs-2025 Quick Start Script
# This script automates the installation and setup of xv6-labs-2025
# Verified on WSL2 environment with Ubuntu 26.04 LTS

# set -e  # Exit on any error - removed to allow QEMU test to fail gracefully

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
sudo apt-get update || { echo "Failed to update package lists"; exit 1; }

# Install required packages
echo "Step 2: Installing required packages..."
sudo apt-get install -y \
    git \
    build-essential \
    gdb-multiarch \
    qemu-system-riscv \
    gcc-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu || { echo "Failed to install packages"; exit 1; }

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
make clean || { echo "Build clean failed"; exit 1; }
make || { echo "Build failed"; exit 1; }

echo ""
echo "Step 6: Testing xv6 with QEMU (10 second timeout)..."
echo "The kernel should boot and show 'xv6 kernel is booting' message."
echo ""

# Run QEMU with timeout to test boot, capture output
echo "Starting QEMU test (this will take 10 seconds)..."
timeout 10 make qemu > /tmp/xv6_test_output.txt 2>&1 &
QEMU_PID=$!

# Wait for timeout to complete
sleep 11

# Check if QEMU process is still running
if ps -p $QEMU_PID > /dev/null; then
    echo "QEMU is still running, killing it..."
    kill $QEMU_PID 2>/dev/null || true
    sleep 1
fi

echo ""
echo "QEMU test completed (timed out after 10 seconds - this is expected)"

# Check if kernel booted successfully
if grep -q "xv6 kernel is booting" /tmp/xv6_test_output.txt; then
    echo "✓ Installation successful! Kernel booted properly."
    echo ""
    echo "Boot output preview:"
    head -n 5 /tmp/xv6_test_output.txt
else
    echo "⚠ Warning: Kernel may not have booted successfully."
    echo "This could be due to QEMU compatibility issues."
    echo "The build completed successfully, so the toolchain is installed correctly."
    echo "You can manually test with: cd $REPO_DIR && make qemu"
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
