#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# ComfyUI Linux Setup Script
# Based on official manual installation guide: https://docs.comfy.org/installation/manual_install#linux
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/ComfyUI"

echo "=========================================="
echo "ComfyUI Linux Setup"
echo "=========================================="
echo ""

# -----------------------------
# Step 1: Check Prerequisites
# -----------------------------
echo -e "${BLUE}[1/6] Checking prerequisites...${NC}"

# Check for NVIDIA GPU
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo -e "${RED}ERROR: nvidia-smi not found${NC}"
    echo "This script requires an NVIDIA GPU with CUDA drivers installed."
    exit 1
fi

echo -e "${GREEN}✓ NVIDIA GPU detected:${NC}"
nvidia-smi --query-gpu=name --format=csv,noheader | head -1

# Check for Python 3.10+
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}ERROR: python3 not found${NC}"
    echo "Install Python 3.10+ first: sudo apt-get install python3 python3-pip python3-venv"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓ Python detected: ${PYTHON_VERSION}${NC}"

# Check for git
if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing git...${NC}"
    sudo apt-get update
    sudo apt-get install -y git
fi

echo -e "${GREEN}✓ Git detected${NC}"
echo ""

# -----------------------------
# Step 2: Clone ComfyUI
# -----------------------------
echo -e "${BLUE}[2/6] Cloning ComfyUI repository...${NC}"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}WARNING: $INSTALL_DIR already exists${NC}"
    read -r -p "Remove and reinstall? (y/n): " choice
    if [[ "${choice,,}" == "y" ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "Exiting to avoid overwriting existing installation."
        exit 0
    fi
fi

git clone https://github.com/comfyanonymous/ComfyUI.git "$INSTALL_DIR"
cd "$INSTALL_DIR"
echo -e "${GREEN}✓ ComfyUI cloned to $INSTALL_DIR${NC}"
echo ""

# -----------------------------
# Step 3: Create Virtual Environment
# -----------------------------
echo -e "${BLUE}[3/6] Creating Python virtual environment...${NC}"

python3 -m venv venv
source venv/bin/activate

echo -e "${GREEN}✓ Virtual environment created and activated${NC}"
echo ""

# -----------------------------
# Step 4: Install PyTorch with CUDA Support
# -----------------------------
echo -e "${BLUE}[4/6] Installing PyTorch with CUDA 12.1 support...${NC}"
echo "This may take several minutes..."

pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

echo -e "${GREEN}✓ PyTorch installed${NC}"
echo ""

# -----------------------------
# Step 5: Install ComfyUI Dependencies
# -----------------------------
echo -e "${BLUE}[5/6] Installing ComfyUI dependencies...${NC}"

pip install -r requirements.txt

echo -e "${GREEN}✓ ComfyUI dependencies installed${NC}"
echo ""

# -----------------------------
# Step 6: Install ComfyUI Manager
# -----------------------------
echo -e "${BLUE}[6/6] Installing ComfyUI Manager...${NC}"

cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git

echo -e "${GREEN}✓ ComfyUI Manager installed${NC}"
echo ""

# -----------------------------
# Create convenience scripts
# -----------------------------
echo -e "${BLUE}Creating convenience scripts...${NC}"

# Create start script
cat > "$INSTALL_DIR/start-comfyui.sh" << 'STARTSCRIPT'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8188
STARTSCRIPT

chmod +x "$INSTALL_DIR/start-comfyui.sh"

# Create systemd service file (optional)
cat > "$INSTALL_DIR/comfyui.service" << SERVICEEOF
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/python main.py --listen 0.0.0.0 --port 8188
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF

echo -e "${GREEN}✓ Convenience scripts created${NC}"
echo ""

# -----------------------------
# Summary
# -----------------------------
echo "=========================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=========================================="
echo ""
echo "ComfyUI is installed at: $INSTALL_DIR"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Download models (run from this directory):"
echo "   cd $(pwd)"
echo "   ./download-models.sh"
echo ""
echo "2. Copy your custom LoRA to ComfyUI models folder:"
echo "   cp /path/to/your-lora.safetensors $INSTALL_DIR/models/loras/"
echo ""
echo "3. Start ComfyUI:"
echo "   cd $INSTALL_DIR"
echo "   ./start-comfyui.sh"
echo ""
echo "   OR activate venv manually:"
echo "   cd $INSTALL_DIR"
echo "   source venv/bin/activate"
echo "   python main.py --listen 0.0.0.0 --port 8188"
echo ""
echo "4. Access ComfyUI at: http://localhost:8188"
echo ""
echo -e "${YELLOW}Optional: Install as systemd service (auto-start on boot)${NC}"
echo "   sudo cp $INSTALL_DIR/comfyui.service /etc/systemd/system/"
echo "   sudo systemctl enable comfyui"
echo "   sudo systemctl start comfyui"
echo ""
echo -e "${YELLOW}Using ComfyUI Manager:${NC}"
echo "   - Open ComfyUI at http://localhost:8188"
echo "   - Click 'Manager' button in the UI"
echo "   - Install custom nodes (like WanVideoWrapper) directly from the UI"
echo "   - No manual pip installs needed!"
echo ""
echo "=========================================="
