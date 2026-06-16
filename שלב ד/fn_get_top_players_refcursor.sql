-- ======================================================================================
-- fn_get_top_players_refcursor.sql
-- פונקציה 2
-- תיאור: מקבלת קוד מועדון ומחזירה Ref Cursor ל-5 השחקנים עם מד הכושר הקלאסי הגבוה ביותר.
-- מאפיינים: Ref Cursor, Exceptions.
-- ======================================================================================

CREATE OR REPLACE FUNCTION fn_get_top_players_refcursor(p_club_id INT)
RETURNS refcursor AS $$
DECLARE
    rc refcursor;
    v_club_exists BOOLEAN;
BEGIN
    -- בדיקת קיום המועדון
    SELECT EXISTS(SELECT 1 FROM Club WHERE club_id = p_club_id)
    INTO v_club_exists;
    
    IF NOT v_club_exists THEN
        RAISE EXCEPTION 'Club with ID % does not exist', p_club_id;
    END IF;

    -- פתיחת הסמן עבור השאילתה המבוקשת
    OPEN rc FOR 
        SELECT p.player_id, p.username, p.rating_classical 
        FROM Player p
        JOIN club_membership cm ON p.player_id = cm.player_id
        WHERE cm.club_id = p_club_id AND cm.left_date IS NULL
        ORDER BY p.rating_classical DESC NULLS LAST
        LIMIT 5;

    RETURN rc;
END;
$$ LANGUAGE plpgsql;
