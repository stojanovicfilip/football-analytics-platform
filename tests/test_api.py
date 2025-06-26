from api.fbr_client import FBRClient
import sys
from pathlib import Path

project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))


class FBRClientTester:
    def __init__(self):
        self.client = self._setup_client()

    def _setup_client(self):
        """Initialize FBR client with API key"""
        root_dir = Path(__file__).parent.parent
        env_file = root_dir / '.env'

        with open(env_file, 'r') as f:
            api_key = f.read().strip().split('=')[1]

        return FBRClient(api_key)

    def test_endpoint(self, endpoint_name, **kwargs):
        """Test a specific endpoint with given parameters"""
        print(f"\n🧪 Testing {endpoint_name}...")

        if endpoint_name == 'countries':
            result = self.client.get_countries()
        elif endpoint_name == 'leagues':
            result = self.client.get_leagues(kwargs.get('country_code', 'ENG'))
        elif endpoint_name == 'league_seasons':
            result = self.client.get_league_seasons(kwargs.get('league_id', 9))
        elif endpoint_name == 'league_standings':
            result = self.client.get_league_standings(
                kwargs.get('league_id', 9),
                kwargs.get('season_id')
            )
        elif endpoint_name == 'team_season_stats':
            result = self.client.get_team_season_stats(
                kwargs.get('league_id', 9),
                kwargs.get('season_id')
            )
        # ... add other endpoints ...
        else:
            print(f"❌ Unknown endpoint: {endpoint_name}")
            return None

        if result:
            print(f"✅ Success! Found data")
            self._print_result_summary(result)
            return result
        else:
            print("❌ Failed to get data")
            return None

    def _print_result_summary(self, result):
        """Print a summary of the API result"""
        print(f"📊 Response keys: {list(result.keys())}")
        if 'data' in result:
            if isinstance(result['data'], list):
                print(f"📈 Data items: {len(result['data'])}")
                if len(result['data']) > 0:
                    print(
                        f"🔍 First item keys: {list(result['data'][0].keys())}")
            else:
                print(f"🔍 Data keys: {list(result['data'].keys())}")

    def run_basic_tests(self):
        """Run a sequence of basic tests"""
        print("🚀 Running basic API tests...")

        # Test basic endpoints
        self.test_endpoint('countries')
        self.test_endpoint('leagues', country_code='ENG')
        self.test_endpoint('league_seasons', league_id=9)

        print("\n✅ Basic tests completed!")


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Test FBR API endpoints')
    parser.add_argument('endpoint', nargs='?', help='Endpoint to test')
    parser.add_argument('--league-id', type=int, default=9, help='League ID')
    parser.add_argument('--country-code', default='ENG', help='Country code')
    parser.add_argument('--season-id', help='Season ID')

    args = parser.parse_args()

    tester = FBRClientTester()

    if args.endpoint:
        # Test specific endpoint
        kwargs = {
            'league_id': args.league_id,
            'country_code': args.country_code,
            'season_id': args.season_id
        }
        tester.test_endpoint(args.endpoint, **kwargs)
    else:
        # Run basic test suite
        tester.run_basic_tests()

        print("\n💡 For specific tests, use:")
        print("  python tests/test_fbr_client.py countries")
        print("  python tests/test_fbr_client.py leagues --country-code ENG")
        print("  python tests/test_fbr_client.py league_seasons --league-id 9")
        print("  python tests/test_fbr_client.py league_standings --league-id 9 --season-id 2023-2024")


if __name__ == "__main__":
    main()
