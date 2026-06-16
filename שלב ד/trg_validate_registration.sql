-- ======================================================================================
-- trg_validate_registration.sql
-- טריגר 2 
-- תיאור: מופעל בעת הוספה או עדכון של רשומה בטבלת הרשמות (Registration).
-- הטריגר מוודא שתאריך ההרשמה איננו מאוחר מתאריך התחלת הטורניר.
-- ======================================================================================

-- 1. יצירת פונקציית הטריגר
CREATE OR REPLACE FUNCTION fn_trg_validate_registration()
RETURNS TRIGGER AS $$
DECLARE
    v_tournament_start_date DATE;
BEGIN
    -- שליפת תאריך ההתחלה של הטורניר
    SELECT start_date INTO v_tournament_start_date
    FROM Tournament
    WHERE tournament_id = NEW.tournament_id;

    -- בדיקה האם ההרשמה התבצעה אחרי שהטורניר כבר התחיל
    IF NEW.registered_date > v_tournament_start_date THEN
        RAISE EXCEPTION 'Cannot register for tournament % after its start date (%)', 
            NEW.tournament_id, v_tournament_start_date;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. קישור הטריגר לטבלה
DROP TRIGGER IF EXISTS trg_validate_registration ON Registration;

CREATE TRIGGER trg_validate_registration
BEFORE INSERT OR UPDATE OF registered_date, tournament_id ON Registration
FOR EACH ROW
EXECUTE FUNCTION fn_trg_validate_registration();
