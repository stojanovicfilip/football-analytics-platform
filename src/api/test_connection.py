import requests
import sys
from pathlib import Path


def generate_fbr_api_key():
    url = "https://fbrapi.com/generate_api_key"
    try:
        response = requests.post(url)
        response.raise_for_status()
        api_key = response.json()['api_key']
        print(f"✅ API Key generated: {api_key}")

        root_dir = Path(__file__).parent.parent.parent
        env_file = root_dir / '.env'

        with open(env_file, 'w') as f:
            f.write(f"FBR_API_KEY={api_key}\n")
        print(f"💾 Saved to {env_file}")

        return api_key
    except requests.exceptions.RequestException as e:
        print(f"❌ Error generating API key: {e}")
        return None


def test_connection(source):
    """Test connection for different APIs"""
    if source == 'fbr':
        return generate_fbr_api_key()
    else:
        print(f"❌ Unknown source: {source}")
        return None


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python test_connection.py <source>")
        print("Available sources: fbr")
        sys.exit(1)

    source = sys.argv[1]
    test_result = test_connection(source)
    print(f"Result: {test_result}")
