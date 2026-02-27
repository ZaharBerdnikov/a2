"""
Simple calculator skill
Performs basic arithmetic operations
"""

def main(operation="add", a=0, b=0, **kwargs):
    """
    Performs arithmetic operation
    
    Args:
        operation: "add", "subtract", "multiply", "divide"
        a: First number
        b: Second number
        **kwargs: Additional parameters
        
    Returns:
        dict: Calculation result
    """
    operations = {
        "add": a + b,
        "subtract": a - b,
        "multiply": a * b,
        "divide": a / b if b != 0 else "Error: Division by zero"
    }
    
    result = operations.get(operation, "Error: Unknown operation")
    
    return {
        "operation": operation,
        "a": a,
        "b": b,
        "result": result,
        "success": operation in operations and not isinstance(result, str)
    }
