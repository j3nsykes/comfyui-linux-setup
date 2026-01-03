# ComfyUI Direct Linux Installation

This is a **much simpler** alternative to the Docker setup. All the dependency conflicts you encountered with Docker are avoided by installing ComfyUI directly on your Linux VM.

## Why Use This Instead of Docker?

- ✅ No Docker complexity or dependency conflicts
- ✅ ComfyUI Manager works perfectly out of the box
- ✅ Easier to debug and troubleshoot
- ✅ No pip resolver bugs
- ✅ Faster startup (no container overhead)
- ✅ Everything persists automatically (it's just files on your VM)

## Prerequisites

- Ubuntu/Debian Linux VM (like Paperspace)
- NVIDIA GPU with CUDA drivers installed
- Python 3.10 or higher
- At least 100GB free disk space (for models)

## One-Time Setup

### Step 1: Run the Setup Script

```bash
cd ~/Desktop/Comfyui-Containers-main/comfyui-docker
chmod +x setup-comfyui-linux.sh
./setup-comfyui-linux.sh
```

This script will:
- Check for prerequisites (Python, NVIDIA GPU, git)
- Clone ComfyUI to `~/ComfyUI`
- Create a Python virtual environment
- Install PyTorch with CUDA 12.1 support
- Install all ComfyUI dependencies
- Install ComfyUI Manager
- Create convenience start scripts

**Time required:** 5-10 minutes

### Step 2: Download Models

After setup completes:

```bash
# Authenticate with HuggingFace (one-time only)
hf auth login

# Download all required models (~80-90GB)
cd ~/Desktop/Comfyui-Containers-main/comfyui-docker
./download-models.sh
```

The script will ask where to save models. Use:
```
~/ComfyUI/models
```

**Time required:** 30-60 minutes depending on internet speed

### Step 3: Copy Your Custom LoRA

```bash
cp /path/to/cc16515b-*.safetensors ~/ComfyUI/models/loras/
```

### Step 4: Install Custom Nodes (WanVideoWrapper, etc.)

Start ComfyUI:
```bash
cd ~/ComfyUI
./start-comfyui.sh
```

Then:
1. Open browser to http://localhost:8188
2. Click the **"Manager"** button in the UI
3. Click **"Install Custom Nodes"**
4. Search for "WanVideoWrapper" and install it
5. Search for any other nodes you need and install them
6. Restart ComfyUI when prompted

ComfyUI Manager will automatically install all Python dependencies for each custom node. **No manual pip installs needed!**

## Daily Usage

### Starting ComfyUI

**Option 1: Use the convenience script**
```bash
cd ~/ComfyUI
./start-comfyui.sh
```

**Option 2: Manual activation**
```bash
cd ~/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8188
```

Then access at: http://localhost:8188

### Stopping ComfyUI

Press `Ctrl+C` in the terminal where ComfyUI is running.

### VM Restart Workflow

When your VM restarts, just run:
```bash
cd ~/ComfyUI
./start-comfyui.sh
```

Everything persists automatically - your custom nodes, models, and workflows are all still there.

## Optional: Auto-Start on Boot

If you want ComfyUI to start automatically when the VM boots:

```bash
sudo cp ~/ComfyUI/comfyui.service /etc/systemd/system/
sudo systemctl enable comfyui
sudo systemctl start comfyui
```

**Manage the service:**
```bash
# Check status
sudo systemctl status comfyui

# View logs
sudo journalctl -u comfyui -f

# Stop service
sudo systemctl stop comfyui

# Restart service
sudo systemctl restart comfyui
```

## File Structure

```
~/ComfyUI/
├── venv/                    # Python virtual environment
├── models/                  # All your downloaded models
│   ├── diffusion_models/    # Wan 2.2 models
│   ├── text_encoders/       # UMT5 encoder
│   ├── vae/                 # VAE decoder
│   ├── loras/               # LoRA files (including your custom one)
│   └── midas/               # Depth models
├── custom_nodes/            # Installed custom nodes
│   ├── ComfyUI-Manager/     # ComfyUI Manager
│   └── ComfyUI-WanVideoWrapper/  # After you install it
├── input/                   # Input files
├── output/                  # Generated videos/images
├── main.py                  # ComfyUI main script
├── start-comfyui.sh        # Convenience start script
└── comfyui.service         # Systemd service file
```

## Updating ComfyUI

To update ComfyUI to the latest version:

```bash
cd ~/ComfyUI
source venv/bin/activate
git pull
pip install -r requirements.txt --upgrade
```

## Updating Custom Nodes

Use ComfyUI Manager:
1. Open ComfyUI at http://localhost:8188
2. Click "Manager" → "Update All"

## Troubleshooting

### ComfyUI won't start

**Check Python version:**
```bash
python3 --version  # Should be 3.10 or higher
```

**Check NVIDIA drivers:**
```bash
nvidia-smi
```

**Check virtual environment:**
```bash
cd ~/ComfyUI
source venv/bin/activate
which python  # Should show ~/ComfyUI/venv/bin/python
```

### Custom nodes not loading

**Check if dependencies installed:**
```bash
cd ~/ComfyUI
source venv/bin/activate
cd custom_nodes/ComfyUI-WanVideoWrapper
pip install -r requirements.txt
```

**Check ComfyUI logs:**
- ComfyUI prints detailed error messages in the terminal
- Look for red ERROR messages

### Models not found

**Verify models are in correct location:**
```bash
ls -lh ~/ComfyUI/models/diffusion_models/
ls -lh ~/ComfyUI/models/text_encoders/
ls -lh ~/ComfyUI/models/vae/
ls -lh ~/ComfyUI/models/loras/
```

**If models are elsewhere, create symlinks:**
```bash
# If your models are in a different location
ln -s /path/to/actual/models ~/ComfyUI/models
```

### Out of disk space

**Check available space:**
```bash
df -h ~
```

Models take ~80-90GB. Ensure you have at least 100GB free.

### Port 8188 already in use

**Find what's using the port:**
```bash
sudo lsof -i :8188
```

**Use a different port:**
```bash
cd ~/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8189
```

## For Multiple VMs

To set up the same environment on multiple VMs:

### Method 1: Run setup script on each VM

1. Copy the entire `Comfyui-Containers-main` folder to each VM
2. Run `./setup-comfyui-linux.sh` on each VM
3. Run `./download-models.sh` on each VM (or copy models folder)

### Method 2: Create a tarball after first setup

**On first VM (after complete setup):**
```bash
cd ~
tar -czf comfyui-backup.tar.gz ComfyUI/
```

**Transfer to other VMs:**
```bash
# On new VM
scp user@first-vm:~/comfyui-backup.tar.gz ~/
cd ~
tar -xzf comfyui-backup.tar.gz
cd ComfyUI
./start-comfyui.sh
```

This includes everything: ComfyUI, models, custom nodes, and virtual environment.

## Comparison: Docker vs Direct Install

| Feature | Docker | Direct Install |
|---------|--------|----------------|
| Setup complexity | High | Low |
| Dependency issues | Frequent | Rare |
| ComfyUI Manager | Problematic | Works perfectly |
| Startup time | ~30 seconds | ~5 seconds |
| Debugging | Harder | Easier |
| Portability | Better | Good enough |
| Disk usage | Higher (layers) | Lower |
| GPU access | Requires config | Direct |

For your use case (persistent VM setup for client), **direct install is recommended**.

## Getting Help

If you encounter issues:
1. Check the ComfyUI logs (printed in terminal)
2. Check ComfyUI Manager logs (in the UI)
3. Visit ComfyUI Discord or GitHub issues
4. Official docs: https://docs.comfy.org/
