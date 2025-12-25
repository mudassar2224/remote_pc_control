import random
import string

# Store active PCs
# code -> websocket
ACTIVE_PC_CONNECTIONS = {}

def generate_pairing_code():
    """Generate a 6-digit numeric code"""
    return ''.join(random.choices(string.digits, k=6))
