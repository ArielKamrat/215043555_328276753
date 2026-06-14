-- ==========================================
-- בדיקת Commit
-- ==========================================
-- הערה: לפני הרצת הפקודות, ודאו בתוכנה שלכם ש-Auto Commit כבוי (לרוב זה כפתור של מנעול או V למעלה ב-DBeaver/Oracle SQL Developer).

-- שלב 1: התחלת טרנזקציה (אם ה-Auto commit כבוי, פעולת העדכון פותחת טרנזקציה אוטומטית, אך בחלק מהמסדים דרוש BEGIN)
BEGIN;

-- שלב 2: עדכון נתון בבסיס הנתונים (שינוי שם של מועדון 1)
UPDATE Club SET name = 'Grand Chess Club' WHERE club_id = 1;

-- שלב 3: הצגת המצב (פה עושים צילום מסך שמראה שהשם השתנה ל-Grand Chess Club)
SELECT * FROM Club WHERE club_id = 1;

-- שלב 4: ביצוע Commit
COMMIT;

-- שלב 5: הצגת המצב לאחר ה-Commit (המצב נשאר מעודכן, לצלם מסך)
SELECT * FROM Club WHERE club_id = 1;


-- ==========================================
-- בדיקת Rollback
-- ==========================================

-- שלב 1: התחלת טרנזקציה
BEGIN;

-- שלב 2: עדכון נתון בבסיס הנתונים (שינוי שגוי שאנחנו נרצה לבטל)
UPDATE Club SET name = 'Wrong Name Delete Me' WHERE club_id = 2;

-- שלב 3: הצגת המצב (צילום מסך שמראה שהשם עכשיו שגוי)
SELECT * FROM Club WHERE club_id = 2;

-- שלב 4: ביצוע Rollback (ביטול השינויים)
ROLLBACK;

-- שלב 5: הצגת המצב לאחר ה-Rollback (צילום מסך שמראה שהשם חזר לקדמותו המקורית)
SELECT * FROM Club WHERE club_id = 2;
