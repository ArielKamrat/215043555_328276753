-- ======================================================================================
-- pr_close_tournament_and_score.sql
-- פרוצדורה 1
-- תיאור: סגירת טורניר, ועדכון הניקוד המצטבר של כל שחקן שנרשם אליו בהתאם לתוצאות המשחקים.
-- מאפיינים: Explicit Cursor, שימוש ב-Record, לולאות, הסתעפויות, פקודות DML, חריגות.
-- ======================================================================================

CREATE OR REPLACE PROCEDURE pr_close_tournament_and_score(p_tournament_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
    v_end_date DATE;
    v_game_rec RECORD;
    
    -- Explicit Cursor (סמן מפורש) שעובר על כל המשחקים של הטורניר
    cur_games CURSOR FOR 
        SELECT g.white_player_id, g.black_player_id, g.result 
        FROM Game g
        JOIN roundresult rr ON g.game_id = rr.game_id
        JOIN Round r ON rr.round_id = r.round_id
        WHERE r.tournament_id = p_tournament_id;
BEGIN
    -- קריאת פרטי הטורניר
    SELECT status, end_date INTO v_status, v_end_date
    FROM Tournament
    WHERE tournament_id = p_tournament_id;

    -- בדיקת קיום הטורניר
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tournament % not found', p_tournament_id;
    END IF;

    -- בדיקה האם כבר סגור
    IF v_status = 'Closed' THEN
        RAISE EXCEPTION 'Tournament % is already closed', p_tournament_id;
    END IF;

    -- בדיקה האם הגיע הזמן לסגור (תאריך הסיום עבר)
    -- IF v_end_date >= CURRENT_DATE THEN
    --    RAISE NOTICE 'Tournament % end date has not passed yet, but forcing close for demonstration.', p_tournament_id;
    -- END IF;

    -- אתחול ציוני הרשמות לאפס כדי למנוע כפילויות
    UPDATE Registration SET total_score = 0.0 WHERE tournament_id = p_tournament_id;

    -- לולאה באמצעות הסמן המפורש לעדכון ניקוד
    OPEN cur_games;
    LOOP
        FETCH cur_games INTO v_game_rec;
        EXIT WHEN NOT FOUND;
        
        IF v_game_rec.result = '1-0' THEN
            UPDATE Registration SET total_score = total_score + 1.0 
            WHERE tournament_id = p_tournament_id AND player_id = v_game_rec.white_player_id;
        ELSIF v_game_rec.result = '0-1' THEN
            UPDATE Registration SET total_score = total_score + 1.0 
            WHERE tournament_id = p_tournament_id AND player_id = v_game_rec.black_player_id;
        ELSIF v_game_rec.result = '1/2-1/2' THEN
            UPDATE Registration SET total_score = total_score + 0.5 
            WHERE tournament_id = p_tournament_id AND player_id = v_game_rec.white_player_id;
            
            UPDATE Registration SET total_score = total_score + 0.5 
            WHERE tournament_id = p_tournament_id AND player_id = v_game_rec.black_player_id;
        END IF;
    END LOOP;
    CLOSE cur_games;

    -- סגירת הטורניר
    UPDATE Tournament SET status = 'Closed' WHERE tournament_id = p_tournament_id;
    
    RAISE NOTICE 'Tournament % successfully closed and scores updated.', p_tournament_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Failed to close tournament %: %', p_tournament_id, SQLERRM;
        ROLLBACK;
END;
$$;
