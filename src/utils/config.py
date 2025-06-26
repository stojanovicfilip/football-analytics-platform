from pathlib import Path
from api.fbr_client import FBRClient


def get_api_key():
    """Read API key from .env file"""
    root_dir = Path(__file__).parent.parent.parent
    env_file = root_dir / '.env'

    with open(env_file, 'r') as f:
        return f.read().strip().split('=')[1]


def create_fbr_client():
    """Create configured FBR client"""
    api_key = get_api_key()
    return FBRClient(api_key)
