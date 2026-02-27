"""
Simple Hello World skill
Demonstrates basic parameter handling
"""

def main(name="World", **kwargs):
    """
    Returns a greeting message
    
    Args:
        name: Name to greet (default: "World")
        **kwargs: Additional parameters
        
    Returns:
        dict: Greeting result
    """
    return {
        "greeting": f"Hello, {name}!",
        "additional_params": kwargs,
        "status": "success"
    }
