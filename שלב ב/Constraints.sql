-- ==========================================
-- 3 אילוצים חדשים (Constraints)
-- ==========================================

-- 1. אילוץ המגביל את השם של השחקן (username) להיות לפחות בעל 3 תווים.
ALTER TABLE Player ADD CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3);

-- בדיקת שגיאה (הריצו שורה זו בנפרד כדי לראות שהאילוץ פועל, היא אמורה לזרוק שגיאה):
-- INSERT INTO Player (player_id, username) VALUES (999, 'ab');

-- 2. אילוץ המגביל את סוגי הסטטוס בטבלת ההרשמות לסטטוסים מורשים בלבד.
ALTER TABLE Registration ADD CONSTRAINT chk_reg_status CHECK (status IN ('Pending', 'Confirmed', 'Expired', 'Cancelled', 'Waiting'));

-- בדיקת שגיאה (הריצו כדי לקבל שגיאה):
-- INSERT INTO Registration (reg_id, tournament_id, player_id, registered_date, status) VALUES (999, 1, 1, CURRENT_DATE, 'UnknownStatus');

-- 3. אילוץ המחייב שזמן בסיס (base_seconds) בסוג משחק יהיה מספר חיובי ממש.
ALTER TABLE TimeControl ADD CONSTRAINT chk_base_seconds CHECK (base_seconds > 0);

-- בדיקת שגיאה (הריצו כדי לקבל שגיאה):
-- INSERT INTO TimeControl (tc_id, name, base_seconds, increment_seconds) VALUES (999, 'Invalid TC', 0, 0);
