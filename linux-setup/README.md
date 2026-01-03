# Direct Linux Installation for ComfyUI

This folder contains everything you need for a **simple, Docker-free** ComfyUI installation on your Linux VM.

## What's in This Folder

1. **`README-CHOOSE-YOUR-PATH.md`** - START HERE
   - Explains Direct Install vs Docker
   - Helps you choose the right approach
   - Recommends Direct Install for your use case

2. **`setup-comfyui-linux.sh`** - Main setup script
   - One-command installation
   - Installs ComfyUI to `~/ComfyUI`
   - Sets up virtual environment
   - Installs all dependencies
   - Creates convenience scripts

3. **`download-models-linux.sh`** - Model downloader
   - Downloads ~80-90GB of Wan 2.2 models
   - Saves to `~/ComfyUI/models`
   - Skips existing files

4. **`LINUX-INSTALL-README.md`** - Complete documentation
   - Detailed setup instructions
   - Daily usage guide
   - Troubleshooting
   - Multi-VM deployment
   - Client handoff instructions

5. **`QUICK-REFERENCE.md`** - Quick command reference
   - One-page cheat sheet
   - Common commands
   - Troubleshooting shortcuts

## Quick Start

```bash
# 1. Make scripts executable
cd linux-setup
chmod +x setup-comfyui-linux.sh download-models-linux.sh

# 2. Run setup (5-10 minutes)
./setup-comfyui-linux.sh

# 3. Authenticate with HuggingFace
hf auth login

# 4. Download models (30-60 minutes)
./download-models-linux.sh

# 5. Start ComfyUI
cd ~/ComfyUI
./start-comfyui.sh

# 6. Open browser to http://localhost:8188
# 7. Install WanVideoWrapper via Manager UI
```

## Why Use This Instead of Docker?

- ✅ No dependency conflicts
- ✅ No pip resolver bugs
- ✅ ComfyUI Manager works perfectly
- ✅ Easier to debug
- ✅ Faster startup
- ✅ Simpler for clients

## Need Help?

1. Read `README-CHOOSE-YOUR-PATH.md` first
2. For detailed instructions: `LINUX-INSTALL-README.md`
3. For quick commands: `QUICK-REFERENCE.md`

## What About Docker?

The Docker setup files are in the parent directory. If you've been fighting Docker dependency issues, the direct Linux install is much simpler and more reliable for your use case.
