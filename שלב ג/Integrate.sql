-- ======================================================================================
-- Integrate.sql
-- שלב ג: מיזוג מסד הנתונים של קבוצה 8309_7002 (משתמשים ומועדונים) 
-- אל מסד הנתונים הקיים שלנו (תחרויות ומשחקים).
-- ======================================================================================

-- 1. יצירת טבלאות הייחוס (Lookup Tables) של המערכת השנייה
CREATE TABLE player_status (
    status_code VARCHAR(30) PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE membership_role (
    role_code VARCHAR(30) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE membership_status (
    status_code VARCHAR(30) PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE subscription_status (
    status_code VARCHAR(30) PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE billing_cycle (
    billing_cycle_code VARCHAR(30) PRIMARY KEY,
    billing_cycle_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE login_status (
    status_code VARCHAR(30) PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE social_connection_type (
    type_code VARCHAR(30) PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE social_connection_status (
    status_code VARCHAR(30) PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

-- 2. הרחבת טבלת Player הקיימת שלנו עם השדות של המערכת השנייה
-- (מניחים שטבלת Player שלנו קיימת ומכילה player_id, username)
ALTER TABLE Player 
    ADD COLUMN email VARCHAR(100) UNIQUE,
    ADD COLUMN first_name VARCHAR(50),
    ADD COLUMN last_name VARCHAR(50),
    ADD COLUMN country_code CHAR(2),
    ADD COLUMN city VARCHAR(80),
    ADD COLUMN language_code VARCHAR(10),
    ADD COLUMN status_code VARCHAR(30),
    ADD COLUMN rating_classical INTEGER DEFAULT 1200 CHECK (rating_classical >= 0),
    ADD COLUMN rating_rapid INTEGER DEFAULT 1200 CHECK (rating_rapid >= 0),
    ADD COLUMN rating_blitz INTEGER DEFAULT 1200 CHECK (rating_blitz >= 0),
    ADD COLUMN birth_date DATE,
    ADD COLUMN registration_date DATE,
    ADD CONSTRAINT fk_player_status FOREIGN KEY (status_code) REFERENCES player_status(status_code);

-- 3. הרחבת טבלת Club הקיימת שלנו עם השדות של המערכת השנייה
ALTER TABLE Club RENAME COLUMN name TO club_name;

ALTER TABLE Club
    ADD COLUMN country_code CHAR(2),
    ADD COLUMN city VARCHAR(80),
    ADD COLUMN description VARCHAR(500),
    ADD COLUMN logo_url VARCHAR(255),
    ADD COLUMN is_official BOOLEAN DEFAULT FALSE,
    ADD COLUMN founded_date DATE;

-- 4. יצירת שאר הטבלאות הראשיות מהמערכת השנייה המסתמכות על Player ו-Club
CREATE TABLE subscription_tier (
    tier_id INT PRIMARY KEY,
    tier_name VARCHAR(50) NOT NULL UNIQUE,
    price_monthly NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (price_monthly >= 0),
    price_annual NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (price_annual >= 0),
    max_daily_games INTEGER NOT NULL DEFAULT 0 CHECK (max_daily_games >= 0),
    has_analytics BOOLEAN NOT NULL DEFAULT FALSE,
    has_puzzles BOOLEAN NOT NULL DEFAULT FALSE,
    has_engine BOOLEAN NOT NULL DEFAULT FALSE,
    description VARCHAR(500)
);

CREATE TABLE club_membership (
    membership_id INT PRIMARY KEY,
    player_id INT NOT NULL,
    club_id INT NOT NULL,
    role_code VARCHAR(30) NOT NULL,
    invited_by_player_id INT,
    status_code VARCHAR(30) NOT NULL,
    join_date DATE NOT NULL,
    left_date DATE,
    CONSTRAINT fk_membership_player FOREIGN KEY (player_id) REFERENCES Player(player_id),
    CONSTRAINT fk_membership_club FOREIGN KEY (club_id) REFERENCES Club(club_id),
    CONSTRAINT fk_membership_role FOREIGN KEY (role_code) REFERENCES membership_role(role_code),
    CONSTRAINT fk_membership_inviter FOREIGN KEY (invited_by_player_id) REFERENCES Player(player_id),
    CONSTRAINT fk_membership_status FOREIGN KEY (status_code) REFERENCES membership_status(status_code),
    CONSTRAINT chk_membership_dates CHECK (left_date IS NULL OR left_date >= join_date),
    CONSTRAINT chk_membership_inviter_not_self CHECK (invited_by_player_id IS NULL OR invited_by_player_id <> player_id)
);

CREATE TABLE player_subscription (
    subscription_id INT PRIMARY KEY,
    player_id INT NOT NULL,
    tier_id INT NOT NULL,
    payment_method_id INT,
    status_code VARCHAR(30) NOT NULL,
    billing_cycle_code VARCHAR(30) NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT FALSE,
    start_date DATE NOT NULL,
    end_date DATE,
    next_billing_date DATE,
    CONSTRAINT fk_subscription_player FOREIGN KEY (player_id) REFERENCES Player(player_id),
    CONSTRAINT fk_subscription_tier FOREIGN KEY (tier_id) REFERENCES subscription_tier(tier_id),
    CONSTRAINT fk_subscription_status FOREIGN KEY (status_code) REFERENCES subscription_status(status_code),
    CONSTRAINT fk_subscription_billing_cycle FOREIGN KEY (billing_cycle_code) REFERENCES billing_cycle(billing_cycle_code),
    CONSTRAINT chk_subscription_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_subscription_next_billing CHECK (next_billing_date IS NULL OR next_billing_date >= start_date)
);

CREATE TABLE login_log (
    log_id INT PRIMARY KEY,
    player_id INT NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    country_detected CHAR(2),
    city_detected VARCHAR(80),
    device_type VARCHAR(30) NOT NULL,
    operating_system VARCHAR(40) NOT NULL,
    browser VARCHAR(40) NOT NULL,
    login_status_code VARCHAR(30) NOT NULL,
    failure_reason VARCHAR(100),
    session_duration_sec INTEGER NOT NULL DEFAULT 0 CHECK (session_duration_sec >= 0),
    is_suspicious BOOLEAN NOT NULL DEFAULT FALSE,
    login_date DATE NOT NULL,
    CONSTRAINT fk_login_player FOREIGN KEY (player_id) REFERENCES Player(player_id),
    CONSTRAINT fk_login_status FOREIGN KEY (login_status_code) REFERENCES login_status(status_code),
    CONSTRAINT chk_login_failure_reason CHECK (
        (login_status_code = 'success' AND failure_reason IS NULL) OR
        (login_status_code IN ('failed', 'blocked')) OR
        (login_status_code NOT IN ('success', 'failed', 'blocked'))
    )
);

CREATE TABLE social_connection (
    connection_id INT PRIMARY KEY,
    from_player_id INT NOT NULL,
    to_player_id INT NOT NULL,
    connection_type_code VARCHAR(30) NOT NULL,
    status_code VARCHAR(30) NOT NULL,
    created_date DATE NOT NULL,
    CONSTRAINT fk_connection_from_player FOREIGN KEY (from_player_id) REFERENCES Player(player_id),
    CONSTRAINT fk_connection_to_player FOREIGN KEY (to_player_id) REFERENCES Player(player_id),
    CONSTRAINT fk_connection_type FOREIGN KEY (connection_type_code) REFERENCES social_connection_type(type_code),
    CONSTRAINT fk_connection_status FOREIGN KEY (status_code) REFERENCES social_connection_status(status_code),
    CONSTRAINT chk_connection_not_self CHECK (from_player_id <> to_player_id),
    CONSTRAINT uq_connection_unique UNIQUE (from_player_id, to_player_id, connection_type_code)
);
