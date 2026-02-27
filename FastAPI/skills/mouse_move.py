"""
Mouse move skill using pyautogui
Moves the mouse cursor to specified coordinates
"""

def main(x, y, duration=0.5, **kwargs):
    """
    Move the mouse cursor to specified coordinates
    
    Args:
        x (int): X coordinate on the screen
        y (int): Y coordinate on the screen
        duration (float): Time in seconds for the movement (default: 0.5)
        **kwargs: Additional parameters
        
    Returns:
        dict: Result of the mouse movement
    """
    try:
        import pyautogui
        
        # Move the mouse to the specified coordinates
        pyautogui.moveTo(x, y, duration=duration)
        
        # Get current mouse position to confirm
        current_x, current_y = pyautogui.position()
        
        return {
            "success": True,
            "target": {"x": x, "y": y},
            "actual": {"x": current_x, "y": current_y},
            "duration": duration,
            "message": f"Mouse moved to ({x}, {y})"
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"{type(e).__name__}: {str(e)}",
            "target": {"x": x, "y": y}
        }
