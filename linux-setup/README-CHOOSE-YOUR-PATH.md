# ComfyUI Setup - Choose Your Path

You have **two options** for setting up ComfyUI on your Linux VM. Choose based on your needs:

---

## ⭐ RECOMMENDED: Direct Linux Install

**Best for:** Your use case (persistent VM setup for client use)

### Pros
- ✅ Simple and straightforward
- ✅ No dependency conflicts
- ✅ ComfyUI Manager works perfectly
- ✅ Easier to debug
- ✅ Faster startup (~5 seconds)
- ✅ Everything persists automatically

### Cons
- ❌ Less portable (but you don't need portability)
- ❌ Not isolated from system Python (but this rarely matters)

### Quick Start
```bash
chmod +x setup-comfyui-linux.sh
./setup-comfyui-linux.sh
./download-models-linux.sh
cd ~/ComfyUI
./start-comfyui.sh
```

**Read:** `LINUX-INSTALL-README.md` for full instructions

---

## Docker Install

**Best for:** If you need full isolation or plan to deploy to many different VMs frequently

### Pros
- ✅ Fully isolated environment
- ✅ Can rebuild on any VM with Docker
- ✅ Container portability

### Cons
- ❌ Complex dependency conflicts (pip resolver bugs)
- ❌ ComfyUI Manager may have issues
- ❌ Harder to debug
- ❌ Slower startup (~30 seconds)
- ❌ Requires rebuilding when things break

### Quick Start
```bash
docker-compose build --no-cache
docker-compose up -d
./download-models.sh  # Save to ./models
```

**Read:** `PERSISTENCE-README.md` for Docker instructions

---

## Recommendation

**Use Direct Linux Install** because:

1. You've already encountered multiple pip dependency conflicts with Docker
2. Your workflow is: set up VM → client uses it → VM persists
3. You're not deploying to hundreds of VMs daily
4. Someone else needs to use it without technical knowledge
5. Simplicity and reliability matter more than isolation

The Docker approach makes sense when:
- You need to deploy to 50+ VMs
- You're running multiple conflicting Python projects
- You need guaranteed reproducibility across different OS versions
- You're comfortable debugging container issues

For your case (Paperspace VM for client), **go with the direct install**. It's:
- Faster to set up
- Easier to maintain
- More reliable
- Simpler for your client to use

---

## Files in This Directory

### Direct Linux Install
- `setup-comfyui-linux.sh` - One-time setup script
- `download-models-linux.sh` - Download models to ~/ComfyUI/models
- `LINUX-INSTALL-README.md` - Full documentation
- `QUICK-REFERENCE.md` - Quick command reference

### Docker Install
- `Dockerfile.comfyui` - Docker image definition
- `docker-compose.yml` - Docker runtime config
- `startup.sh` - Container startup script
- `download-models.sh` - Download models to ./models
- `PERSISTENCE-README.md` - Docker documentation
- `TROUBLESHOOTING.md` - Docker troubleshooting

### Workflow Files
- `wan2_2-video-rm.json` - Main video generation workflow
- `rm-manual-wan2_2.json` - Depth analysis workflow

---

## Still Undecided?

Try the **direct Linux install first**. If you encounter issues or decide you need Docker later, you can always switch. Going from direct install → Docker is easy. Going from Docker → direct install (which you're considering now) means you've already hit the complexity wall.

**Time investment:**
- Direct install: 5-10 minutes setup + 30-60 min model download
- Docker: 10-20 minutes debugging dependency issues + rebuilds + same model download

Choose simplicity. Your future self (and your client) will thank you.
