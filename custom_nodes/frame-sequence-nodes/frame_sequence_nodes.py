import torch
import os
import json
import numpy as np
from PIL import Image
import folder_paths

class FrameSelector:
    """
    Selects a single frame from a video batch.
    Use with ComfyUI's queue system - set frame_index and queue multiple times.
    ComfyUI will auto-increment the index for batch processing.
    """
    
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "images": ("IMAGE",),
                "frame_index": ("INT", {
                    "default": 0, 
                    "min": 0, 
                    "max": 10000,
                    "step": 1,
                    "control_after_generate": True  # Auto-increment when queued
                }),
            }
        }
    
    RETURN_TYPES = ("IMAGE", "INT")
    RETURN_NAMES = ("frame", "total_frames")
    FUNCTION = "select_frame"
    CATEGORY = "image/video"
    
    def select_frame(self, images, frame_index):
        """Select a single frame from the batch"""
        batch_size = images.shape[0]
        
        if frame_index >= batch_size:
            print(f"Warning: frame_index {frame_index} >= batch_size {batch_size}, using last frame")
            frame_index = batch_size - 1
        
        # Return single frame (keep batch dimension)
        selected_frame = images[frame_index:frame_index+1]
        
        return (selected_frame, batch_size)


class SaveImageSequence:
    """
    Saves images to a specific folder with sequential numbering.
    Works with queue-based processing for frame sequences.
    Outputs next_frame_index for feeding back to Load Video's skip_first_frames.
    """
    
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "images": ("IMAGE",),
                "folder_name": ("STRING", {"default": "depth_frames"}),
                "frame_index": ("INT", {
                    "default": 0,
                    "min": 0,
                    "max": 10000,
                    "step": 1,
                    "control_after_generate": True
                }),
            }
        }
    
    RETURN_TYPES = ("STRING", "INT")
    RETURN_NAMES = ("folder_path", "next_frame_index")
    FUNCTION = "save_sequence"
    OUTPUT_NODE = True
    CATEGORY = "image/video"
    
    def save_sequence(self, images, folder_name, frame_index):
        """Save image to sequence folder and return next frame index"""
        # Get output directory
        output_dir = folder_paths.get_output_directory()
        sequence_dir = os.path.join(output_dir, folder_name)
        
        # Create directory if it doesn't exist
        os.makedirs(sequence_dir, exist_ok=True)
        
        # Convert tensor to PIL image
        for i, image in enumerate(images):
            # Convert from torch tensor (H,W,C) in range [0,1] to PIL
            img_np = (image.cpu().numpy() * 255).astype(np.uint8)
            img_pil = Image.fromarray(img_np)
            
            # Save with zero-padded frame number
            filename = f"frame_{frame_index:04d}.png"
            filepath = os.path.join(sequence_dir, filename)
            img_pil.save(filepath)
            
            print(f"Saved: {filepath}")
        
        # Return next frame index for skip_first_frames
        next_frame = frame_index + 1
        
        return (sequence_dir, next_frame)


class LoadImageSequence:
    """
    Loads all images from a folder as a batch.
    Use after processing all frames with SaveImageSequence.
    """
    
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "folder_path": ("STRING", {"default": "depth_frames"}),
            }
        }
    
    RETURN_TYPES = ("IMAGE", "INT")
    RETURN_NAMES = ("images", "frame_count")
    FUNCTION = "load_sequence"
    CATEGORY = "image/video"
    
    def load_sequence(self, folder_path):
        """Load all images from folder as batch"""
        # Handle both absolute and relative paths
        if not os.path.isabs(folder_path):
            output_dir = folder_paths.get_output_directory()
            folder_path = os.path.join(output_dir, folder_path)
        
        if not os.path.exists(folder_path):
            raise ValueError(f"Folder not found: {folder_path}")
        
        # Get all PNG files, sorted
        image_files = sorted([f for f in os.listdir(folder_path) if f.endswith('.png')])
        
        if not image_files:
            raise ValueError(f"No PNG files found in: {folder_path}")
        
        # Load all images
        images = []
        for filename in image_files:
            filepath = os.path.join(folder_path, filename)
            img_pil = Image.open(filepath).convert('RGB')
            img_np = np.array(img_pil).astype(np.float32) / 255.0
            img_tensor = torch.from_numpy(img_np)
            images.append(img_tensor)
        
        # Stack into batch
        batch = torch.stack(images, dim=0)
        
        print(f"Loaded {len(images)} frames from {folder_path}")
        
        return (batch, len(images))


NODE_CLASS_MAPPINGS = {
    "FrameSelector": FrameSelector,
    "SaveImageSequence": SaveImageSequence,
    "LoadImageSequence": LoadImageSequence,
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "FrameSelector": "Select Frame from Video",
    "SaveImageSequence": "Save Image Sequence",
    "LoadImageSequence": "Load Image Sequence",
}
