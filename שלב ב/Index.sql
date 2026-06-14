-- ==========================================
-- 3 אינדקסים
-- ==========================================

-- 1. אינדקס על שדה התוצאה בטבלת המשחקים (יעזור משמעותית בשאילתות שסוכמות ניצחונות והפסדים)
CREATE INDEX idx_game_result ON Game(result);

-- שאילתת בדיקה להרצה לפני ואחרי הוספת האינדקס:
-- EXPLAIN PLAN FOR SELECT result, COUNT(*) FROM Game GROUP BY result;

-- 2. אינדקס על שדה הסטטוס בטבלת ההרשמות (יזרז שאילתות שמסננות נרשמים לפי סטטוס)
CREATE INDEX idx_registration_status ON Registration(status);

-- שאילתת בדיקה להרצה לפני ואחרי:
-- EXPLAIN PLAN FOR SELECT * FROM Registration WHERE status = 'Confirmed';

-- 3. אינדקס על שדה תאריך התחלה בטבלת הטורנירים (מייעל שאילתות סינון לפי שנים/חודשים)
CREATE INDEX idx_tournament_start_date ON Tournament(start_date);

-- שאילתת בדיקה להרצה לפני ואחרי:
-- EXPLAIN PLAN FOR SELECT * FROM Tournament WHERE EXTRACT(YEAR FROM start_date) = 2024;
