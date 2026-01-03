# Frame-by-Frame Video Processing Workflow

## NEW NODES ADDED

**Frame Sequence Nodes:**
- `Select Frame from Video` - Extracts one frame at a time from video batch
- `Save Image Sequence` - Saves frames to a specific folder with sequential numbering
- `Load Image Sequence` - Loads all frames from folder back as a batch

## COMPLETE WORKFLOW

### PART 1: Process Each Frame (Queue 48 times)

```
Load Video (48 frames)
  ↓
Select Frame from Video
  - frame_index: 0 (will auto-increment with each queue)
  ↓
Image Tile (2 rows, 3 cols)
  ↓
Depth Anything V2
  ↓
Image Untile (2 rows, 3 cols)
  ↓
Save Image Sequence
  - folder_name: "depth_frames" (or whatever you want)
  - frame_index: 0 (same as Select Frame - will auto-increment)
```

**How to run:**
1. Set up the workflow above
2. In ComfyUI, set **Queue Count to 48** (or however many frames you have)
3. Click "Queue Prompt"
4. ComfyUI will automatically run 48 times, incrementing frame_index each time
5. All processed frames get saved to `ComfyUI/output/depth_frames/`

### PART 2: Combine Frames Back to Video (Run once after Part 1 completes)

```
Load Image Sequence
  - folder_path: "depth_frames" (match the folder from Part 1)
  ↓
VHS Video Combine
  - Set your framerate (8 fps to match your video)
  - format: video/h264-mp4
  ↓
Output video
```

## KEY FEATURES

✓ **Fully Automated** - No manual file browsing needed
✓ **Auto-increment** - frame_index increases automatically with each queue
✓ **Predictable Paths** - Save and load use the same folder name
✓ **Clean Output** - Frames are numbered: frame_0000.png, frame_0001.png, etc.

## EXAMPLE SETTINGS

**For 48 frames:**
- Queue Count: 48
- frame_index: starts at 0, auto-increments to 47

**For different frame counts:**
- Just change Queue Count to match your video's frame count
- The nodes will handle everything else automatically

## TROUBLESHOOTING

**Issue:** Frames not saving
**Solution:** Check ComfyUI console for the save path, make sure folder permissions are correct

**Issue:** Load Image Sequence can't find folder
**Solution:** Use the exact same folder_name in both Save and Load nodes

**Issue:** Video has wrong frame count
**Solution:** Make sure Queue Count matches your video's frame_count from Load Video

## WORKFLOW TIPS

1. **Test with 3 frames first** - Set Queue Count to 3 to make sure it works before processing all 48
2. **Clear the folder** - Delete old frames from the folder before running a new batch
3. **Monitor progress** - Watch the console to see each frame being processed
