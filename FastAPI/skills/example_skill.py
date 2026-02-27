"""
Example skill demonstrating basic functionality
This is a sample skill that can be executed via the API
"""

import datetime
import json

def main(**kwargs):
    """
    Main function that will be called by the API
    
    Args:
        **kwargs: Parameters passed from API call
        
    Returns:
        dict: Result of the skill execution
    """
    # Get current timestamp
    timestamp = datetime.datetime.now().isoformat()
    
    # Get parameters or use defaults
    name = kwargs.get('name', 'World')
    greeting_type = kwargs.get('greeting_type', 'Hello')
    
    # Create response
    result = {
        "timestamp": timestamp,
        "message": f"{greeting_type}, {name}!",
        "params_received": kwargs,
        "skill_info": {
            "name": "example_skill",
            "version": "1.0.0",
            "description": "Example demonstration skill"
        }
    }
    
    return result


if __name__ == "__main__":
    # For testing purposes
    print(json.dumps(main(name="Test User"), indent=2, ensure_ascii=False))
