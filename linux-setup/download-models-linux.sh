#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# ComfyUI model downloader for Linux direct install
# Downloads models to ~/ComfyUI/models
# - Compatible with hf CLI that uses: hf auth login / hf auth whoami
# - Uses Comfy-Org repackaged repo for Wan 2.2
# -----------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "ComfyUI Model Download Helper"
echo "=========================================="
echo ""

# Default to ~/ComfyUI/models, but allow override
DEFAULT_MODEL_DIR="$HOME/ComfyUI/models"
echo -e "${YELLOW}Where should models be downloaded?${NC}"
echo "Default: $DEFAULT_MODEL_DIR"
read -r -p "Press Enter for default, or type custom path: " MODEL_DIR
MODEL_DIR="${MODEL_DIR:-$DEFAULT_MODEL_DIR}"

# Expand ~ if present
MODEL_DIR="${MODEL_DIR/#\~/$HOME}"

echo ""
echo "Models will be downloaded to: $MODEL_DIR"
echo ""

# Always find user-installed CLI tools
export PATH="$HOME/.local/bin:$PATH"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo -e "${RED}Missing command:${NC} $1"
    return 1
  fi
  return 0
}

# Ensure python3 exists
if ! need_cmd python3; then
  echo -e "${RED}Install python3 first:${NC} sudo apt-get update && sudo apt-get install -y python3"
  exit 1
fi

# Ensure pip exists
if ! python3 -m pip --version >/dev/null 2>&1; then
  echo -e "${YELLOW}pip not found. Installing python3-pip...${NC}"
  sudo apt-get update
  sudo apt-get install -y python3-pip
fi

# Ensure hf exists
if ! need_cmd hf; then
  echo -e "${YELLOW}Hugging Face CLI (hf) not found. Installing huggingface-hub...${NC}"
  python3 -m pip install --user -U huggingface-hub
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! need_cmd hf; then
  echo -e "${RED}Error:${NC} 'hf' still not found after install."
  echo -e "${YELLOW}Try:${NC} export PATH=\"\$HOME/.local/bin:\$PATH\""
  exit 1
fi

# Ensure wget exists (for DepthAnything)
if ! need_cmd wget; then
  echo -e "${YELLOW}wget not found. Installing...${NC}"
  sudo apt-get update
  sudo apt-get install -y wget
fi

# Auth check (compatible with your hf CLI)
if ! hf auth whoami >/dev/null 2>&1; then
  echo -e "${YELLOW}You are not logged into Hugging Face.${NC}"
  echo "Run this once in the same user session:"
  echo "  hf auth login"
  exit 1
fi

echo -e "${GREEN}Hugging Face auth OK.${NC}"
echo ""

echo -e "${BLUE}This will download large models (tens of GB).${NC}"
echo "Destination: $MODEL_DIR"
echo ""
read -r -p "Continue? (y/n): " yn
if [[ "${yn,,}" != "y" ]]; then
  echo "Cancelled."
  exit 0
fi

# Create ComfyUI-expected directories
mkdir -p "$MODEL_DIR/diffusion_models" "$MODEL_DIR/text_encoders" "$MODEL_DIR/vae" "$MODEL_DIR/midas" "$MODEL_DIR/loras"

REPO_COMFY="Comfy-Org/Wan_2.2_ComfyUI_Repackaged"
REPO_KIJAI="Kijai/WanVideo_comfy"

download_one() {
  local repo="$1"
  local remote_path="$2"
  local local_dir="$3"
  local filename
  filename=$(basename "$remote_path")
  local full_path="$local_dir/$filename"

  echo ""
  if [ -f "$full_path" ]; then
    echo -e "${YELLOW}File already exists, skipping:${NC} $full_path"
    return 0
  fi

  echo -e "${GREEN}Downloading${NC}"
  echo "Repo : $repo"
  echo "File : $remote_path"
  echo "To   : $local_dir"
  mkdir -p "$local_dir"

  # No --local-dir-use-symlinks flag (your hf doesn't support it)
  hf download "$repo" "$remote_path" --local-dir "$local_dir"
}

echo ""
echo "=========================================="
echo "Downloading Wan 2.2 (Comfy-Org repackaged)"
echo "=========================================="

# Wan 2.2 diffusion models (FP8 - smaller size)
download_one "$REPO_COMFY" "split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors"  "$MODEL_DIR/diffusion_models"
download_one "$REPO_COMFY" "split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" "$MODEL_DIR/diffusion_models"

echo ""
echo "=========================================="
echo "Downloading Additional Models (Kijai repo)"
echo "=========================================="

# Text encoder (BF16 - required by workflow)
download_one "$REPO_KIJAI" "umt5-xxl-enc-bf16.safetensors" "$MODEL_DIR/text_encoders"

# VAE (BF16 - required by workflow)
download_one "$REPO_KIJAI" "Wan2_1_VAE_bf16.safetensors" "$MODEL_DIR/vae"

# LoRA models
download_one "$REPO_KIJAI" "Lightx2v/lightx2v_T2V_14B_cfg_step_distill_v2_lora_rank64_bf16.safetensors" "$MODEL_DIR/loras"

# VACE modules for Fun/Control
download_one "$REPO_KIJAI" "Fun/VACE/Wan2_2_Fun_VACE_module_A14B_LOW_bf16.safetensors" "$MODEL_DIR/diffusion_models"
download_one "$REPO_KIJAI" "Fun/VACE/Wan2_2_Fun_VACE_module_A14B_HIGH_bf16.safetensors" "$MODEL_DIR/diffusion_models"

echo ""
echo "=========================================="
echo "Downloading DepthAnything V2 Large"
echo "=========================================="

DEPTH_URL="https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth"
DEPTH_OUT="$MODEL_DIR/midas/depth_anything_v2_vitl.pth"

if [ -f "$DEPTH_OUT" ]; then
  echo -e "${YELLOW}Depth model already exists, skipping:${NC} $DEPTH_OUT"
else
  echo "Downloading to: $DEPTH_OUT"
  wget -q --show-progress -O "$DEPTH_OUT" "$DEPTH_URL"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}All downloads complete!${NC}"
echo "=========================================="
echo ""
echo "Files are placed here:"
echo "  $MODEL_DIR/diffusion_models/"
echo "  $MODEL_DIR/text_encoders/"
echo "  $MODEL_DIR/vae/"
echo "  $MODEL_DIR/loras/"
echo "  $MODEL_DIR/midas/"
echo ""

echo "Quick verify:"
ls -lh "$MODEL_DIR/diffusion_models" 2>/dev/null || true
ls -lh "$MODEL_DIR/text_encoders" 2>/dev/null || true
ls -lh "$MODEL_DIR/vae" 2>/dev/null || true
ls -lh "$MODEL_DIR/loras" 2>/dev/null || true
ls -lh "$MODEL_DIR/midas" 2>/dev/null || true
echo ""

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Copy your custom LoRA:"
echo "   cp /path/to/cc16515b-*.safetensors $MODEL_DIR/loras/"
echo ""
echo "2. Start ComfyUI:"
echo "   cd ~/ComfyUI"
echo "   ./start-comfyui.sh"
echo ""
echo "3. Install WanVideoWrapper via ComfyUI Manager UI"
echo ""
