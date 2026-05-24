-- ==========================================
-- טבלאות עזר (לצורך מפתחות זרים בלבד לשלב זה)
-- ==========================================
CREATE TABLE Player (
    player_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL
);

CREATE TABLE Club (
    club_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- ==========================================
-- מחלקה 2: משחקים ומהלכים [cite: 12]
-- ==========================================
CREATE TABLE TimeControl (
    tc_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    base_seconds INT NOT NULL,
    increment_seconds INT NOT NULL
);

CREATE TABLE GameVariant (
    variant_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE Game (
    game_id INT PRIMARY KEY,
    white_player_id INT REFERENCES Player(player_id),
    black_player_id INT REFERENCES Player(player_id),
    tc_id INT REFERENCES TimeControl(tc_id),
    variant_id INT REFERENCES GameVariant(variant_id),
    result VARCHAR(10),
    start_date DATE NOT NULL,
    end_date DATE,
    -- אילוץ: תאריך סיום לא יכול להיות לפני תאריך התחלה
    CONSTRAINT chk_game_dates CHECK (end_date >= start_date)
);

CREATE TABLE Move (
    move_id INT PRIMARY KEY,
    game_id INT REFERENCES Game(game_id),
    move_number INT NOT NULL,
    color VARCHAR(5),
    pgn_notation VARCHAR(20) NOT NULL,
    move_timestamp DATE NOT NULL,
    time_spent_ms INT,
    engine_eval_cp INT
);

-- ==========================================
-- מחלקה 3: תחרויות ואירועים [cite: 17]
-- ==========================================
CREATE TABLE Tournament (
    tournament_id INT PRIMARY KEY,
    club_id INT REFERENCES Club(club_id),
    name VARCHAR(100) NOT NULL,
    registration_open_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    -- אילוצים: סדר תאריכים הגיוני
    CONSTRAINT chk_tourney_reg CHECK (start_date >= registration_open_date),
    CONSTRAINT chk_tourney_dates CHECK (end_date >= start_date)
);

CREATE TABLE Registration (
    reg_id INT PRIMARY KEY,
    tournament_id INT REFERENCES Tournament(tournament_id),
    player_id INT REFERENCES Player(player_id),
    registered_date DATE NOT NULL,
    status VARCHAR(20)
);

CREATE TABLE Round (
    round_id INT PRIMARY KEY,
    tournament_id INT REFERENCES Tournament(tournament_id),
    round_number INT NOT NULL,
    scheduled_date DATE NOT NULL
);

CREATE TABLE RoundResult (
    result_id INT PRIMARY KEY,
    round_id INT REFERENCES Round(round_id),
    game_id INT REFERENCES Game(game_id),
    white_points NUMERIC(3,1),
    black_points NUMERIC(3,1)
);