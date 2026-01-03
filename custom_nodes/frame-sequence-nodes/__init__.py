"""
Simple Image Grid Operations and Frame Sequence Processing for ComfyUI
"""

try:
    from .image_grid_ops import NODE_CLASS_MAPPINGS as GRID_MAPPINGS, NODE_DISPLAY_NAME_MAPPINGS as GRID_DISPLAY
    from .frame_sequence_nodes import NODE_CLASS_MAPPINGS as FRAME_MAPPINGS, NODE_DISPLAY_NAME_MAPPINGS as FRAME_DISPLAY
    
    # Combine both sets of nodes
    NODE_CLASS_MAPPINGS = {**GRID_MAPPINGS, **FRAME_MAPPINGS}
    NODE_DISPLAY_NAME_MAPPINGS = {**GRID_DISPLAY, **FRAME_DISPLAY}
    
    __all__ = ['NODE_CLASS_MAPPINGS', 'NODE_DISPLAY_NAME_MAPPINGS']
    
    print("✓ Image Grid and Frame Sequence nodes loaded successfully!")
    print(f"  - Grid nodes: {list(GRID_MAPPINGS.keys())}")
    print(f"  - Frame nodes: {list(FRAME_MAPPINGS.keys())}")
    
except Exception as e:
    print(f"✗ Failed to load custom nodes: {e}")
    import traceback
    traceback.print_exc()
    
    # Provide empty mappings so ComfyUI doesn't crash
    NODE_CLASS_MAPPINGS = {}
    NODE_DISPLAY_NAME_MAPPINGS = {}
