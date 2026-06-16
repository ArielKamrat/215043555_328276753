-- ======================================================================================
-- fn_calculate_tournament_activity.sql
-- פונקציה 1
-- תיאור: חישוב אחוז השחקנים הרשומים לטורניר מסוים ששיחקו בו לפחות משחק אחד.
-- מאפיינים: Implicit Cursor (SELECT INTO), הסתעפויות (IF), חריגות (Exception).
-- ======================================================================================

CREATE OR REPLACE FUNCTION fn_calculate_tournament_activity(p_tournament_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total_registered INT;
    v_active_players INT;
    v_activity_percentage NUMERIC(5,2);
    v_tournament_exists BOOLEAN;
BEGIN
    -- בדיקה האם הטורניר קיים
    SELECT EXISTS(SELECT 1 FROM Tournament WHERE tournament_id = p_tournament_id)
    INTO v_tournament_exists;
    
    IF NOT v_tournament_exists THEN
        RAISE EXCEPTION 'Tournament with ID % does not exist.', p_tournament_id;
    END IF;

    -- ספירת סך השחקנים הרשומים לטורניר (Implicit Cursor)
    SELECT COUNT(*) INTO v_total_registered
    FROM Registration
    WHERE tournament_id = p_tournament_id;

    -- אם אין רשומים, מניעת חלוקה באפס והחזרת 0
    IF v_total_registered = 0 THEN
        RETURN 0.00;
    END IF;

    -- ספירת השחקנים ששיחקו לפחות משחק אחד בטורניר
    SELECT COUNT(DISTINCT player_id) INTO v_active_players
    FROM (
        SELECT g.white_player_id AS player_id 
        FROM Game g 
        JOIN roundresult rr ON g.game_id = rr.game_id 
        JOIN Round r ON rr.round_id = r.round_id 
        WHERE r.tournament_id = p_tournament_id
        UNION
        SELECT g.black_player_id AS player_id 
        FROM Game g 
        JOIN roundresult rr ON g.game_id = rr.game_id 
        JOIN Round r ON rr.round_id = r.round_id 
        WHERE r.tournament_id = p_tournament_id
    ) AS active_in_games;

    -- חישוב האחוז
    v_activity_percentage := (v_active_players::NUMERIC / v_total_registered::NUMERIC) * 100.0;
    
    RETURN v_activity_percentage;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'An error occurred during tournament activity calculation: %', SQLERRM;
        RETURN -1.0;
END;
$$ LANGUAGE plpgsql;
