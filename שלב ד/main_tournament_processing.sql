-- ======================================================================================
-- main_tournament_processing.sql
-- תוכנית ראשית 1
-- תיאור: מזמנת את הפונקציה לחישוב פעילות בטורניר מסוים, ולאחר מכן מפעילה את הפרוצדורה
-- שסוגרת אותו ומחשבת את הניקוד הסופי. מציגה את התוצאות ללוג.
-- ======================================================================================

DO $$
DECLARE
    v_target_tournament_id INT := 1; -- דוגמה לטורניר לבדיקה
    v_activity_pct NUMERIC;
BEGIN
    RAISE NOTICE '--- Starting Tournament Processing Main Program ---';
    
    -- 1. זימון פונקציה: חישוב אחוז פעילות
    v_activity_pct := fn_calculate_tournament_activity(v_target_tournament_id);
    
    IF v_activity_pct >= 0 THEN
        RAISE NOTICE 'Tournament % Activity Level: % percent of registered players participated.', 
            v_target_tournament_id, v_activity_pct;
    END IF;
    
    -- 2. זימון פרוצדורה: סגירת הטורניר ועדכון ניקוד
    CALL pr_close_tournament_and_score(v_target_tournament_id);
    
    RAISE NOTICE '--- Tournament Processing Complete ---';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in main program: %', SQLERRM;
END;
$$;
