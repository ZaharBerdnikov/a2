"""
Screenshot skill using pyautogui or mss
Creates a screenshot of the screen and saves it to a file
"""

import os
import sys
from datetime import datetime
from pathlib import Path

def main(filename=None, save_dir=None, region=None, **kwargs):
    """
    Create a screenshot of the screen
    
    Args:
        filename: Name of the screenshot file (without extension). 
                 If not provided, uses timestamp
        save_dir: Directory to save screenshot. 
                 If not provided, uses /tmp/screenshots
        region: Optional tuple (left, top, width, height) for partial screenshot
        **kwargs: Additional parameters
        
    Returns:
        dict: Screenshot result with file path
    """
    try:
        # Try to import and use mss first (more reliable, works without X11 in some cases)
        try:
            import mss
            import mss.tools
            use_mss = True
        except ImportError:
            use_mss = False
        
        if use_mss:
            return _screenshot_mss(filename, save_dir, region)
        
        # Fallback to pyautogui/PIL
        import pyautogui
        
        # Create save directory if not exists
        if save_dir is None:
            save_dir = "/tmp/screenshots"
        
        save_path = Path(save_dir)
        save_path.mkdir(parents=True, exist_ok=True)
        
        # Generate filename if not provided
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"screenshot_{timestamp}"
        
        # Ensure .png extension
        if not filename.endswith('.png'):
            filename += '.png'
        
        # Full path
        filepath = save_path / filename
        
        # Take screenshot
        if region:
            screenshot = pyautogui.screenshot(region=region)
        else:
            screenshot = pyautogui.screenshot()
        
        # Save screenshot
        screenshot.save(str(filepath))
        
        # Get image info
        width, height = screenshot.size
        
        return {
            "success": True,
            "filepath": str(filepath),
            "filename": filename,
            "size": {
                "width": width,
                "height": height
            },
            "region": region,
            "file_size_bytes": filepath.stat().st_size if filepath.exists() else None,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"{type(e).__name__}: {str(e)}",
            "filepath": None
        }


def _screenshot_mss(filename=None, save_dir=None, region=None):
    """
    Take screenshot using mss library (more reliable than pyautogui)
    """
    import mss
    import mss.tools
    from PIL import Image
    import io
    
    # Create save directory if not exists
    if save_dir is None:
        save_dir = "/tmp/screenshots"
    
    save_path = Path(save_dir)
    save_path.mkdir(parents=True, exist_ok=True)
    
    # Generate filename if not provided
    if filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"screenshot_{timestamp}"
    
    # Ensure .png extension
    if not filename.endswith('.png'):
        filename += '.png'
    
    # Full path
    filepath = save_path / filename
    
    with mss.mss() as sct:
        # Get the primary monitor
        if region:
            monitor = {"left": region[0], "top": region[1], "width": region[2], "height": region[3]}
        else:
            monitor = sct.monitors[1]  # Primary monitor
        
        # Capture the screen
        screenshot = sct.grab(monitor)
        
        # Convert to PIL Image
        img = Image.frombytes("RGB", screenshot.size, screenshot.bgra, "raw", "BGRX")
        
        # Save the image
        img.save(str(filepath))
        
        width, height = img.size
        
        return {
            "success": True,
            "filepath": str(filepath),
            "filename": filename,
            "size": {
                "width": width,
                "height": height
            },
            "region": region,
            "file_size_bytes": filepath.stat().st_size if filepath.exists() else None,
            "timestamp": datetime.now().isoformat(),
            "backend": "mss"
        }