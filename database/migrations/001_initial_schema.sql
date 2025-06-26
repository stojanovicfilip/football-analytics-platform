-- Core geographic/competition structure
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code CHAR(3) UNIQUE,
    fbref_id VARCHAR(50),
    association VARCHAR(20) CHECK (association IN ('UEFA', 'CONCACAF', 'CAF', 'AFC', 'CONMEBOL', 'OFC')),
    professional_levels INTEGER,
    number_of_clubs INTEGER,
    number_of_players INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE competition_rules (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    points_for_win INTEGER DEFAULT 3,
    points_for_draw INTEGER DEFAULT 1,
    points_for_loss INTEGER DEFAULT 0,
    format_type VARCHAR(20) CHECK (format_type IN ('league', 'cup', 'tournament')),
    max_teams INTEGER,
    promotion_spots INTEGER DEFAULT 0,
    relegation_spots INTEGER DEFAULT 0,
    playoff_rules TEXT,
    tiebreaker_rules TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE competitions (
    competition_id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES countries(country_id),
    rule_id INTEGER REFERENCES competition_rules(rule_id),
    competition_name VARCHAR(100) NOT NULL,
    competition_format VARCHAR(20) CHECK (competition_format IN ('league', 'cup', 'tournament')),
    competition_scope VARCHAR(20) CHECK (competition_scope IN ('national', 'international')),
    competition_level VARCHAR(20) CHECK (competition_level IN ('club', 'national_team')),
    gender VARCHAR(10) DEFAULT 'male' CHECK (gender IN ('male', 'female', 'mixed')),
    tier INTEGER,
    is_youth BOOLEAN DEFAULT FALSE,
    first_season VARCHAR(10),
    last_season VARCHAR(10),
    fbref_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE seasons (
    season_id SERIAL PRIMARY KEY,
    season_name VARCHAR(20) NOT NULL UNIQUE, -- e.g., "2023-24"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date < end_date)
);

CREATE TABLE competition_seasons (
    competition_season_id SERIAL PRIMARY KEY,
    competition_id INTEGER REFERENCES competitions(competition_id),
    season_id INTEGER REFERENCES seasons(season_id),
    season_name VARCHAR(100), -- e.g., "Premier League 2023-24"
    winner_team_id INTEGER, -- Will reference teams(team_id) - circular dependency resolved later
    runner_up_team_id INTEGER,
    top_scorer_player_id INTEGER, -- Will reference players(player_id) 
    number_of_teams INTEGER,
    total_matches INTEGER,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    start_date DATE,
    end_date DATE,
    fbref_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(competition_id, season_id)
);

CREATE TABLE transfer_windows (
    transfer_window_id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES countries(country_id),
    window_name VARCHAR(50) NOT NULL, -- e.g., "Summer 2024", "Winter 2024"
    window_type VARCHAR(20) CHECK (window_type IN ('summer', 'winter', 'emergency')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    total_transfers INTEGER DEFAULT 0,
    total_spend_euros DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date < end_date)
);

-- Organizational entities
CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES countries(country_id),
    parent_club_id INTEGER REFERENCES teams(team_id), -- For youth/reserve teams
    team_name VARCHAR(100) NOT NULL,
    short_name VARCHAR(50),
    team_code CHAR(3), -- e.g., "MCI", "RMA"
    founded_year INTEGER,
    stadium_name VARCHAR(100),
    team_type VARCHAR(20) DEFAULT 'club' CHECK (team_type IN ('club', 'national', 'youth', 'reserve')),
    gender VARCHAR(10) DEFAULT 'male' CHECK (gender IN ('male', 'female', 'mixed')),
    is_youth BOOLEAN DEFAULT FALSE,
    current_league_id INTEGER, -- Will reference competitions
    squad_size INTEGER DEFAULT 0,
    squad_value_euros DECIMAL(15,2) DEFAULT 0.00,
    fbref_id VARCHAR(50),
    logo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE venues (
    venue_id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES countries(country_id),
    venue_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    capacity INTEGER,
    surface_type VARCHAR(20) DEFAULT 'grass' CHECK (surface_type IN ('grass', 'artificial', 'hybrid')),
    built_year INTEGER,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    home_team_id INTEGER, -- Primary team that uses this venue
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- People entities
CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    birth_country VARCHAR(50),
    birth_place VARCHAR(100),
    nationality_id INTEGER REFERENCES countries(country_id),
    height_cm INTEGER CHECK (height_cm > 0 AND height_cm < 250),
    weight_kg INTEGER CHECK (weight_kg > 0 AND weight_kg < 200),
    footedness VARCHAR(10) CHECK (footedness IN ('right', 'left', 'both')),
    fbref_id VARCHAR(50),
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE managers (
    manager_id SERIAL PRIMARY KEY,
    manager_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    nationality_id INTEGER REFERENCES countries(country_id),
    birth_place VARCHAR(100),
    playing_career_end INTEGER, -- Year they stopped playing
    coaching_license VARCHAR(50),
    preferred_formation VARCHAR(20),
    fbref_id VARCHAR(50),
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE match_officials (
    official_id SERIAL PRIMARY KEY,
    official_name VARCHAR(100) NOT NULL,
    nationality_id INTEGER REFERENCES countries(country_id),
    date_of_birth DATE,
    role_type VARCHAR(20) DEFAULT 'referee' CHECK (role_type IN ('referee', 'assistant', 'var', 'fourth_official')),
    level VARCHAR(20) CHECK (level IN ('fifa', 'uefa', 'national', 'regional')),
    active_since INTEGER, -- Year they started officiating
    fbref_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Position management
CREATE TABLE player_positions (
    position_id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES players(player_id),
    position_name VARCHAR(20) NOT NULL,
    position_category VARCHAR(20) CHECK (position_category IN ('goalkeeper', 'defender', 'midfielder', 'forward')),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(player_id, position_name)
);

-- Association entities (junction tables)
CREATE TABLE player_team_associations (
    association_id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES players(player_id),
    team_id INTEGER REFERENCES teams(team_id),
    start_date DATE NOT NULL,
    end_date DATE,
    jersey_number INTEGER CHECK (jersey_number > 0 AND jersey_number <= 99),
    contract_end_date DATE,
    contract_value_euros DECIMAL(12,2),
    transfer_fee_euros DECIMAL(12,2),
    is_loan BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    position_played VARCHAR(20),
    appearances INTEGER DEFAULT 0,
    goals_scored INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date <= COALESCE(end_date, CURRENT_DATE))
);

CREATE TABLE manager_team_associations (
    association_id SERIAL PRIMARY KEY,
    manager_id INTEGER REFERENCES managers(manager_id),
    team_id INTEGER REFERENCES teams(team_id),
    start_date DATE NOT NULL,
    end_date DATE,
    role_type VARCHAR(20) DEFAULT 'head_coach' CHECK (role_type IN ('head_coach', 'assistant', 'interim', 'caretaker')),
    contract_end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    matches_managed INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date <= COALESCE(end_date, CURRENT_DATE))
);

CREATE TABLE player_injury_associations (
    injury_id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES players(player_id),
    injury_type VARCHAR(50) NOT NULL,
    body_part VARCHAR(50),
    severity VARCHAR(20) CHECK (severity IN ('minor', 'moderate', 'major', 'career_ending')),
    injury_date DATE NOT NULL,
    expected_return_date DATE,
    actual_return_date DATE,
    days_out INTEGER,
    matches_missed INTEGER DEFAULT 0,
    injury_source VARCHAR(20) CHECK (injury_source IN ('match', 'training', 'other')),
    description TEXT,
    is_recurring BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Match structure
CREATE TABLE rounds (
    round_id SERIAL PRIMARY KEY,
    competition_season_id INTEGER REFERENCES competition_seasons(competition_season_id),
    round_number INTEGER NOT NULL,
    round_name VARCHAR(50), -- e.g., "Matchday 1", "Round of 16", "Final"
    round_type VARCHAR(20) CHECK (round_type IN ('group_stage', 'knockout', 'league', 'playoff')),
    start_date DATE,
    end_date DATE,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    round_id INTEGER REFERENCES rounds(round_id),
    venue_id INTEGER REFERENCES venues(venue_id),
    home_team_id INTEGER REFERENCES teams(team_id),
    away_team_id INTEGER REFERENCES teams(team_id),
    match_date TIMESTAMP NOT NULL,
    home_score INTEGER,
    away_score INTEGER,
    home_score_ht INTEGER, -- Half-time scores
    away_score_ht INTEGER,
    match_status VARCHAR(20) DEFAULT 'scheduled' CHECK (match_status IN ('scheduled', 'live', 'completed', 'postponed', 'cancelled')),
    attendance INTEGER,
    referee_id INTEGER REFERENCES match_officials(official_id),
    weather_conditions VARCHAR(50),
    match_duration_minutes INTEGER DEFAULT 90,
    added_time_minutes INTEGER DEFAULT 0,
    fbref_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (home_team_id != away_team_id)
);

-- Match data
CREATE TABLE match_events (
    event_id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(match_id),
    player_id INTEGER REFERENCES players(player_id),
    team_id INTEGER REFERENCES teams(team_id),
    event_type VARCHAR(30) NOT NULL CHECK (event_type IN ('goal', 'assist', 'yellow_card', 'red_card', 'substitution_on', 'substitution_off', 'penalty_scored', 'penalty_missed', 'own_goal')),
    event_minute INTEGER NOT NULL CHECK (event_minute >= 0 AND event_minute <= 120),
    added_time_minute INTEGER DEFAULT 0,
    event_description TEXT,
    x_coordinate DECIMAL(5,2), -- For position on field
    y_coordinate DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE match_metrics (
    metric_id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(match_id),
    player_id INTEGER REFERENCES players(player_id),
    team_id INTEGER REFERENCES teams(team_id),
    minutes_played INTEGER DEFAULT 0,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    shots INTEGER DEFAULT 0,
    shots_on_target INTEGER DEFAULT 0,
    passes_completed INTEGER DEFAULT 0,
    passes_attempted INTEGER DEFAULT 0,
    pass_accuracy DECIMAL(5,2),
    tackles_won INTEGER DEFAULT 0,
    tackles_attempted INTEGER DEFAULT 0,
    interceptions INTEGER DEFAULT 0,
    fouls_committed INTEGER DEFAULT 0,
    fouls_suffered INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    distance_covered_km DECIMAL(4,1),
    touches INTEGER DEFAULT 0,
    dribbles_completed INTEGER DEFAULT 0,
    dribbles_attempted INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transfer system
CREATE TABLE transfer_transactions (
    transfer_id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES players(player_id),
    from_team_id INTEGER REFERENCES teams(team_id),
    to_team_id INTEGER REFERENCES teams(team_id),
    transfer_window_id INTEGER REFERENCES transfer_windows(transfer_window_id),
    transfer_date DATE NOT NULL,
    transfer_type VARCHAR(20) CHECK (transfer_type IN ('permanent', 'loan', 'free', 'exchange')),
    transfer_fee_euros DECIMAL(12,2),
    agent_fee_euros DECIMAL(10,2),
    contract_length_years DECIMAL(3,1),
    announcement_date DATE,
    medical_status VARCHAR(20) DEFAULT 'pending' CHECK (medical_status IN ('pending', 'passed', 'failed')),
    is_official BOOLEAN DEFAULT FALSE,
    fbref_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (from_team_id != to_team_id)
);