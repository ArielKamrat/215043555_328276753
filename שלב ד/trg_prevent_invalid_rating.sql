-- ======================================================================================
-- trg_prevent_invalid_rating.sql
-- טריגר 1 (חובה על UPDATE)
-- תיאור: מופעל בעת עדכון טבלת Player ומוודא שדירוג השחמט לא יורד מתחת ל-0
-- ולא צונח בבת אחת ביותר מ-200 נקודות (במקרה כזה מגביל את הירידה ל-200 מקסימום).
-- ======================================================================================

-- 1. יצירת פונקציית הטריגר
CREATE OR REPLACE FUNCTION fn_trg_prevent_invalid_rating()
RETURNS TRIGGER AS $$
BEGIN
    -- טיפול בדירוג קלאסי
    IF NEW.rating_classical < 0 THEN
        RAISE EXCEPTION 'Classical rating cannot be negative (Attempted: %)', NEW.rating_classical;
    END IF;

    IF OLD.rating_classical - NEW.rating_classical > 200 THEN
        RAISE NOTICE 'Rating drop of > 200 detected for player %. Capping drop to 200.', NEW.player_id;
        NEW.rating_classical := OLD.rating_classical - 200;
    END IF;

    -- טיפול בדירוג בליץ (רק לוודא שלא שלילי)
    IF NEW.rating_blitz < 0 THEN
        NEW.rating_blitz := 0;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. קישור הטריגר לטבלה
DROP TRIGGER IF EXISTS trg_prevent_invalid_rating ON Player;

CREATE TRIGGER trg_prevent_invalid_rating
BEFORE UPDATE OF rating_classical, rating_blitz ON Player
FOR EACH ROW
EXECUTE FUNCTION fn_trg_prevent_invalid_rating();
