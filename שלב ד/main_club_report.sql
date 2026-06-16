-- ======================================================================================
-- main_club_report.sql
-- תוכנית ראשית 2
-- תיאור: מזמנת את הפונקציה לקבלת Ref Cursor של שחקני הצמרת במועדון ומדפיסה אותם.
-- לאחר מכן מזמנת את הפרוצדורה לקידום השחקן החזק ביותר לאדמין.
-- ======================================================================================

DO $$
DECLARE
    v_club_id INT := 2; -- מועדון לבדיקה
    v_refcursor refcursor;
    v_player_rec RECORD;
BEGIN
    RAISE NOTICE '--- Starting Club Management Main Program ---';

    -- 1. זימון הפונקציה שמחזירה Ref Cursor
    v_refcursor := fn_get_top_players_refcursor(v_club_id);
    
    RAISE NOTICE 'Top 5 players for club %:', v_club_id;
    
    -- שימוש בסמן המופנה לפריקת הנתונים
    LOOP
        FETCH v_refcursor INTO v_player_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Player ID: %, Username: %, Classical Rating: %', 
            v_player_rec.player_id, v_player_rec.username, v_player_rec.rating_classical;
    END LOOP;
    
    -- חובה לסגור סמן מופנה
    CLOSE v_refcursor;
    
    -- 2. זימון הפרוצדורה לקידום השחקן המוביל לאדמין
    CALL pr_promote_club_top_player(v_club_id);

    RAISE NOTICE '--- Club Management Complete ---';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in club management program: %', SQLERRM;
END;
$$;
