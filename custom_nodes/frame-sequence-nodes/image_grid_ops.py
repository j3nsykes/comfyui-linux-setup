import torch
import numpy as np

class ImageGridSplit:
    """Split an image into a grid of tiles"""
    
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "image": ("IMAGE",),
                "rows": ("INT", {"default": 2, "min": 1, "max": 10}),
                "cols": ("INT", {"default": 3, "min": 1, "max": 10}),
            }
        }
    
    RETURN_TYPES = ("IMAGE",)
    FUNCTION = "split_grid"
    CATEGORY = "image"
    
    def split_grid(self, image, rows, cols):
        # Image is in format [batch, height, width, channels]
        batch_size, height, width, channels = image.shape
        
        # Only process the first image in the batch
        first_image = image[0:1]  # Keep batch dimension
        
        # Calculate tile dimensions
        tile_height = height // rows
        tile_width = width // cols
        
        tiles = []
        
        # Split into grid
        for row in range(rows):
            for col in range(cols):
                y_start = row * tile_height
                y_end = y_start + tile_height
                x_start = col * tile_width
                x_end = x_start + tile_width
                
                tile = first_image[:, y_start:y_end, x_start:x_end, :]
                tiles.append(tile)
        
        # Stack all tiles into a batch
        output = torch.cat(tiles, dim=0)
        
        return (output,)


class ImageGridMerge:
    """Merge a batch of tiles back into a single image"""
    
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "tiles": ("IMAGE",),
                "rows": ("INT", {"default": 2, "min": 1, "max": 10}),
                "cols": ("INT", {"default": 3, "min": 1, "max": 10}),
            }
        }
    
    RETURN_TYPES = ("IMAGE",)
    FUNCTION = "merge_grid"
    CATEGORY = "image"
    
    def merge_grid(self, tiles, rows, cols):
        # tiles is in format [batch, height, width, channels]
        # batch should equal rows * cols
        batch_size, tile_height, tile_width, channels = tiles.shape
        
        if batch_size != rows * cols:
            raise ValueError(f"Number of tiles ({batch_size}) doesn't match grid size ({rows}x{cols}={rows*cols})")
        
        # Reconstruct the grid
        tile_rows = []
        
        for row in range(rows):
            row_tiles = []
            for col in range(cols):
                idx = row * cols + col
                row_tiles.append(tiles[idx])
            
            # Concatenate tiles horizontally
            row_image = torch.cat(row_tiles, dim=1)  # concatenate along width
            tile_rows.append(row_image)
        
        # Concatenate rows vertically
        output = torch.cat(tile_rows, dim=0)  # concatenate along height
        
        # Add batch dimension back
        output = output.unsqueeze(0)
        
        return (output,)


NODE_CLASS_MAPPINGS = {
    "ImageGridSplit": ImageGridSplit,
    "ImageGridMerge": ImageGridMerge,
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "ImageGridSplit": "Split Image to Grid",
    "ImageGridMerge": "Merge Grid to Image",
}

__all__ = ['NODE_CLASS_MAPPINGS', 'NODE_DISPLAY_NAME_MAPPINGS']
