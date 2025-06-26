import requests
import time


class FBRClient:
    def __init__(self, api_key):
        self.api_key = api_key
        self.url = 'https://fbrapi.com'

    def _make_request(self, endpoint, params=None):
        time.sleep(3)
        response = requests.get(self.url + endpoint,
                                params=params,
                                headers={"X-API-Key": self.api_key})

        if response.status_code == 200:
            return response.json()
        else:
            print(f'Error: {response.status_code}')
            return None

    def get_countries(self):
        """Get list of available countries"""

        endpoint = '/countries'

        return self._make_request(endpoint)

    def get_leagues(self, country_code):
        """Get list of available leagues in a country"""

        endpoint = '/leagues'
        params = {'country_code': country_code}

        return self._make_request(endpoint, params)

    def get_league_seasons(self, league_id):
        """Get available seasons for a specific league"""

        endpoint = '/league-seasons'
        params = {'league_id': league_id}

        return self._make_request(endpoint, params)

    def get_league_standings(self, league_id, season_id=None):
        """Get league standings for a specific league and season"""

        endpoint = '/league-standings'
        params = {
            'league_id': league_id,
            'season_id': season_id
        }

        return self._make_request(endpoint, params)

    def get_team_season_stats(self, league_id, season_id=None):
        """Get season-level team stats for all teams in a league"""

        endpoint = '/team-season-stats'
        params = {
            'league_id': league_id,
            'season_id': season_id
        }

        return self._make_request(endpoint, params)

    def get_player_season_stats(self, team_id, league_id, season_id=None):
        """Get season stats for all players in a team"""

        endpoint = '/player-season-stats'
        params = {
            'team_id': team_id,
            'league_id': league_id,
            'season_id': season_id
        }

        return self._make_request(endpoint, params)

    def get_matches(self, league_id=None, team_id=None, season_id=None):
        """Get match data - can filter by league or team"""

        endpoint = '/matches'
        params = {
            'team_id': team_id,
            'league_id': league_id,
            'season_id': season_id
        }

        return self._make_request(endpoint, params)

    def get_team_match_stats(self, team_id, league_id, season_id):
        """Get match-level team stats for a specific team"""

        endpoint = '/team-match-stats'
        params = {
            'team_id': team_id,
            'league_id': league_id,
            'season_id': season_id
        }

        return self._make_request(endpoint, params)

    def get_all_players_match_stats(self, match_id):
        """Get player stats for all players in a specific match"""

        endpoint = '/all-players-match-stats'
        params = {'match_id': match_id}

        return self._make_request(endpoint, params)
