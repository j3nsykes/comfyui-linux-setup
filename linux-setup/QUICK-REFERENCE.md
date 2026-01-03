# ComfyUI Quick Reference Card

## First Time Setup (One Time Only)

```bash
# 1. Run setup script
cd ~/Desktop/Comfyui-Containers-main/comfyui-docker
chmod +x setup-comfyui-linux.sh
./setup-comfyui-linux.sh

# 2. Authenticate HuggingFace
hf auth login

# 3. Download models (~80-90GB, 30-60 min)
./download-models.sh
# When prompted, enter: ~/ComfyUI/models

# 4. Copy your custom LoRA
cp /path/to/cc16515b-*.safetensors ~/ComfyUI/models/loras/

# 5. Start ComfyUI
cd ~/ComfyUI
./start-comfyui.sh

# 6. Install custom nodes via UI
# Open http://localhost:8188
# Click "Manager" → "Install Custom Nodes"
# Search and install: WanVideoWrapper
```

---

## Daily Usage

### Start ComfyUI
```bash
cd ~/ComfyUI
./start-comfyui.sh
```

Then open: http://localhost:8188

### Stop ComfyUI
Press `Ctrl+C` in the terminal

---

## Common Commands

### Check disk space
```bash
df -h ~
```

### Check GPU status
```bash
nvidia-smi
```

### Update ComfyUI
```bash
cd ~/ComfyUI
source venv/bin/activate
git pull
pip install -r requirements.txt --upgrade
```

### Update custom nodes
Use ComfyUI Manager UI:
- Manager → Update All

### View installed packages
```bash
cd ~/ComfyUI
source venv/bin/activate
pip list
```

### Manually install a custom node's dependencies
```bash
cd ~/ComfyUI
source venv/bin/activate
cd custom_nodes/NODE_NAME
pip install -r requirements.txt
```

---

## File Locations

```
~/ComfyUI/models/diffusion_models/    # Wan 2.2 models
~/ComfyUI/models/text_encoders/       # UMT5 encoder
~/ComfyUI/models/vae/                 # VAE decoder
~/ComfyUI/models/loras/               # LoRA files
~/ComfyUI/models/midas/               # Depth models
~/ComfyUI/custom_nodes/               # Custom nodes
~/ComfyUI/input/                      # Input files
~/ComfyUI/output/                     # Generated outputs
```

---

## Troubleshooting

### ComfyUI won't start
```bash
cd ~/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8188
# Look for red ERROR messages
```

### Custom node missing
```bash
cd ~/ComfyUI
source venv/bin/activate
cd custom_nodes/NODE_NAME
pip install -r requirements.txt
# Then restart ComfyUI
```

### Models not found
```bash
ls -lh ~/ComfyUI/models/diffusion_models/
# Verify files are present
```

### Port 8188 in use
```bash
# Use different port
cd ~/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8189
```

---

## For New VMs

**Option 1: Run setup on each VM**
```bash
# Copy Comfyui-Containers-main folder to new VM
./setup-comfyui-linux.sh
./download-models.sh
```

**Option 2: Clone from existing VM**
```bash
# On working VM
cd ~
tar -czf comfyui-backup.tar.gz ComfyUI/

# Transfer to new VM
scp comfyui-backup.tar.gz user@new-vm:~/
# On new VM
tar -xzf comfyui-backup.tar.gz
cd ComfyUI
./start-comfyui.sh
```

---

## Auto-Start on Boot (Optional)

```bash
sudo cp ~/ComfyUI/comfyui.service /etc/systemd/system/
sudo systemctl enable comfyui
sudo systemctl start comfyui

# Manage service
sudo systemctl status comfyui
sudo systemctl stop comfyui
sudo systemctl restart comfyui
sudo journalctl -u comfyui -f  # View logs
```

---

## Client Handoff Instructions

**Tell your client:**

1. **To start ComfyUI:**
   ```bash
   cd ~/ComfyUI
   ./start-comfyui.sh
   ```
   Then visit: http://localhost:8188

2. **To stop ComfyUI:**
   Press `Ctrl+C`

3. **After VM restart:**
   Just run the start command again - everything persists

4. **To load your workflows:**
   - Drag and drop the `.json` workflow file into the browser
   - All nodes and models should load automatically

That's it! No Docker commands, no rebuilding, no complexity.
