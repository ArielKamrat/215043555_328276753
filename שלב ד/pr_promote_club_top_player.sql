-- ======================================================================================
-- pr_promote_club_top_player.sql
-- פרוצדורה 2
-- תיאור: מקדמת את השחקן החזק ביותר במועדון להיות מנהל ('admin'), אם הוא לא כזה עדיין.
-- מאפיינים: DML (UPDATE), שימוש במשתנים, הסתעפויות (IF).
-- ======================================================================================

CREATE OR REPLACE PROCEDURE pr_promote_club_top_player(p_club_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_top_player_id INT;
    v_current_role VARCHAR(30);
BEGIN
    -- מציאת השחקן הטוב ביותר (הראשון בדירוג הקלאסי)
    SELECT p.player_id, cm.role_code INTO v_top_player_id, v_current_role
    FROM Player p
    JOIN club_membership cm ON p.player_id = cm.player_id
    WHERE cm.club_id = p_club_id AND cm.left_date IS NULL
    ORDER BY p.rating_classical DESC NULLS LAST
    LIMIT 1;

    -- בדיקה אם נמצא שחקן
    IF v_top_player_id IS NULL THEN
        RAISE NOTICE 'No active players found in club % to promote.', p_club_id;
        RETURN;
    END IF;

    -- בדיקה אם כבר מנהל או בעלים
    IF v_current_role IN ('admin', 'owner') THEN
        RAISE NOTICE 'Top player % is already an % in club %.', v_top_player_id, v_current_role, p_club_id;
    ELSE
        -- עדכון תפקיד למנהל (admin)
        UPDATE club_membership
        SET role_code = 'admin'
        WHERE player_id = v_top_player_id AND club_id = p_club_id AND left_date IS NULL;
        
        RAISE NOTICE 'Successfully promoted top player % to admin in club %.', v_top_player_id, p_club_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to promote player: %', SQLERRM;
END;
$$;
