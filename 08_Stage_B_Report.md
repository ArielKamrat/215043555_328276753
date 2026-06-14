# דוח הפרויקט - שלב ב'

במסגרת שלב ב' של הפרויקט ביצענו שאילתות Select מורכבות (חלקן בשתי דרכים להשוואת יעילות), שאילתות עדכון ומחיקה, הוספת אילוצים (Constraints), אינדקסים, ושימוש בפקודות Rollback ו-Commit.

---

## 1. שאילתות SELECT כפולות (השוואת יעילות)

### שאילתא 1: מציאת שחקנים שמעולם לא נרשמו לאף טורניר
**תיאור:** השאילתא מחזירה שחקנים שאין להם שום רשומה בטבלת ההרשמות (Registration).
**דרך א' (`NOT IN`):** 
```sql
SELECT username, player_id 
FROM Player 
WHERE player_id NOT IN (SELECT player_id FROM Registration WHERE player_id IS NOT NULL);
```
![הרצה דרך א'](שלב ב/q1_way1.png)

**דרך ב' (`LEFT JOIN` ו-`IS NULL`):**
```sql
SELECT p.username, p.player_id 
FROM Player p 
LEFT JOIN Registration r ON p.player_id = r.player_id 
WHERE r.player_id IS NULL;
```
![הרצה דרך ב'](שלב ב/q1_way2.png)

**הסבר והבדלי יעילות:**
דרך ב' (LEFT JOIN) לרוב יעילה יותר ממחיצות גדולות, שכן היא נמנעת מסריקה מלאה של תת-השאילתא עבור כל שורה בטבלת השחקנים כפי שעלול לקרות ב-NOT IN, ומבצעת במקום זאת פעולת Hash Join או Merge Join פשוטה.

---

### שאילתא 2: מציאת כמות המשחקים לשחקנים ששיחקו מעל 5 משחקים
**תיאור:** ספירת כמות המשחקים לכל שחקן והצגת השחקנים ששיחקו יותר מ-5 משחקים.
**דרך א' (`GROUP BY` ו-`HAVING`):**
```sql
SELECT p.username, COUNT(g.game_id) as total_games
FROM Player p
JOIN Game g ON p.player_id = g.white_player_id OR p.player_id = g.black_player_id
GROUP BY p.player_id, p.username
HAVING COUNT(g.game_id) > 5;
```
![הרצה דרך א'](שלב ב/q2_way1.png)

**דרך ב' (תת-שאילתא מסונכרנת - Correlated Subquery):**
```sql
SELECT p.username, (
    SELECT COUNT(*) FROM Game g WHERE g.white_player_id = p.player_id OR g.black_player_id = p.player_id
) as total_games
FROM Player p
WHERE (SELECT COUNT(*) FROM Game g WHERE g.white_player_id = p.player_id OR g.black_player_id = p.player_id) > 5;
```
![הרצה דרך ב'](שלב ב/q2_way2.png)

**הסבר והבדלי יעילות:**
דרך א' יעילה משמעותית. בדרך ב' תת-השאילתא מורצת עבור כל שחקן (Correlated Subquery) ועוד פעמיים (פעם ב-SELECT ופעם ב-WHERE). בדרך א', מסד הנתונים סורק ומקבץ את הנתונים פעם אחת בלבד.

---

### שאילתא 3: מציאת שחקנים ששיחקו לפחות משחק אחד בסוג זמן מסוים (למשל tc_id=1)
**תיאור:** החזרת שחקנים שהשתתפו במשחק שבו הוגדר זמן משחק ספציפי.
**דרך א' (`JOIN` ו-`DISTINCT`):**
```sql
SELECT DISTINCT p.username, p.player_id, tc.name as time_control_name
FROM Player p
JOIN Game g ON p.player_id = g.white_player_id OR p.player_id = g.black_player_id
JOIN TimeControl tc ON g.tc_id = tc.tc_id
WHERE tc.tc_id = 1;
```
![הרצה דרך א'](שלב ב/q3_way1.png)

**דרך ב' (`EXISTS`):**
```sql
SELECT p.username, p.player_id, (SELECT name FROM TimeControl WHERE tc_id = 1) as time_control_name
FROM Player p
WHERE EXISTS (
    SELECT 1 FROM Game g 
    WHERE (g.white_player_id = p.player_id OR g.black_player_id = p.player_id) 
    AND g.tc_id = 1
);
```
![הרצה דרך ב'](שלב ב/q3_way2.png)

**הסבר והבדלי יעילות:**
פקודת `EXISTS` (דרך ב') מהירה יותר לרוב כאשר יש כפילויות רבות, משום שהיא עוצרת את הסריקה ברגע שהיא מוצאת את ההתאמה הראשונה (Short-circuit). לעומת זאת, ה-JOIN מבצע הצלבה עבור כל המשחקים ולאחר מכן צריך להפעיל DISTINCT כדי לסנן כפילויות, פעולה שצורכת משאבים רבים.

---

### שאילתא 4: חיפוש משחקים שבהם השתתף שחקן מס' 1
**תיאור:** מציאת כל המשחקים (לבן או שחור) שבהם שיחק player_id = 1.
**דרך א' (שימוש ב-`OR`):**
```sql
SELECT game_id, white_player_id, black_player_id, start_date
FROM Game
WHERE white_player_id = 1 OR black_player_id = 1;
```
![הרצה דרך א'](שלב ב/q4_way1.png)

**דרך ב' (שימוש ב-`UNION`):**
```sql
SELECT game_id, white_player_id, black_player_id, start_date
FROM Game WHERE white_player_id = 1
UNION
SELECT game_id, white_player_id, black_player_id, start_date
FROM Game WHERE black_player_id = 1;
```
![הרצה דרך ב'](שלב ב/q4_way2.png)

**הסבר והבדלי יעילות:**
בחלק ממנועי מסדי הנתונים, שימוש ב-UNION יכול להיות יעיל יותר משום שהוא מאפשר למנוע החיפוש (Optimizer) להשתמש בשני אינדקסים נפרדים (אחד לשחקן לבן ואחד לשחקן שחור) ולאחד את התוצאות, בעוד ששימוש ב-OR עלול לגרום למנוע לבצע סריקת טבלה מלאה (Full Table Scan).

---

## 2. שאילתות SELECT רגילות

### שאילתא 5: משחקים במסגרת סבבים משנת 2025
**תיאור:** רשימת המשחקים ששוחקו בסבב מתוכנן לשנת 2025, כולל שמות השחקנים, תוך חילוץ השנה מתוך שדה התאריך.
```sql
SELECT g.game_id, pw.username as white_player, pb.username as black_player, r.scheduled_date
FROM Game g
JOIN RoundResult rr ON g.game_id = rr.game_id
JOIN Round r ON rr.round_id = r.round_id
JOIN Player pw ON g.white_player_id = pw.player_id
JOIN Player pb ON g.black_player_id = pb.player_id
WHERE EXTRACT(YEAR FROM r.scheduled_date) = 2025
ORDER BY r.scheduled_date DESC;
```
![תוצאה שאילתא 5](שלב ב/q5_result.png)

### שאילתא 6: סכימת ניצחונות לפי סוג משחק
**תיאור:** חישוב והשוואת כמות הניצחונות ללבן מול שחור לפי כל Game Variant (שימוש בפונקציות סכימה ו-CASE).
```sql
SELECT v.name as variant_name, 
       SUM(CASE WHEN g.result = '1-0' THEN 1 ELSE 0 END) as white_wins,
       SUM(CASE WHEN g.result = '0-1' THEN 1 ELSE 0 END) as black_wins
FROM Game g
JOIN GameVariant v ON g.variant_id = v.variant_id
GROUP BY v.name;
```
![תוצאה שאילתא 6](שלב ב/q6_result.png)

### שאילתא 7: משחקים ארוכים (מעל 30 מהלכים)
**תיאור:** הצגת המשחקים שבהם היו יותר מ-30 מהלכים, מסודרים מהגבוה לנמוך.
```sql
SELECT g.game_id, pw.username as white_player, pb.username as black_player, COUNT(m.move_id) as total_moves
FROM Game g
JOIN Player pw ON g.white_player_id = pw.player_id
JOIN Player pb ON g.black_player_id = pb.player_id
JOIN Move m ON g.game_id = m.game_id
GROUP BY g.game_id, pw.username, pb.username
HAVING COUNT(m.move_id) > 30
ORDER BY total_moves DESC;
```
![תוצאה שאילתא 7](שלב ב/q7_result.png)

### שאילתא 8: טורנירים ללא סבבים
**תיאור:** מציאת טורנירים שהוגדרו במערכת אך עדיין לא נקבעו להם סבבים כלל (שימוש ב-LEFT JOIN).
```sql
SELECT t.tournament_id, t.name, t.start_date
FROM Tournament t
JOIN Club c ON t.club_id = c.club_id
LEFT JOIN Round rnd ON t.tournament_id = rnd.tournament_id
WHERE rnd.round_id IS NULL;
```
![תוצאה שאילתא 8](שלב ב/q8_result.png)

---

## 3. שאילתות DELETE

**שאילתא 1: מחיקת משחקים עתידיים ללא תוצאה**
```sql
DELETE FROM Game WHERE start_date > CURRENT_DATE AND result IS NULL;
```
![לפני שאילתא 1](שלב ב/delete1_before.png)
![הרצה שאילתא 1](שלב ב/delete1_run.png)
![אחרי שאילתא 1](שלב ב/delete1_after.png)

**שאילתא 2: מחיקת טורנירים ישנים (לפני 2022)**
```sql
DELETE FROM Tournament WHERE EXTRACT(YEAR FROM end_date) < 2022;
```
![לפני שאילתא 2](שלב ב/delete2_before.png)
![הרצה שאילתא 2](שלב ב/delete2_run.png)
![אחרי שאילתא 2](שלב ב/delete2_after.png)

**שאילתא 3: מחיקת סבבים שנקבעו בטעות לפני תחילת הטורניר**
```sql
DELETE FROM Round 
WHERE scheduled_date < (SELECT start_date FROM Tournament t WHERE t.tournament_id = Round.tournament_id);
```
![לפני שאילתא 3](שלב ב/delete3_before.png)
![הרצה שאילתא 3](שלב ב/delete3_run.png)
![אחרי שאילתא 3](שלב ב/delete3_after.png)

---

## 4. שאילתות UPDATE

**שאילתא 1: עדכון סוג זמן משחק (tc_id) לפי תוצאות**
```sql
UPDATE Game SET tc_id = 2 WHERE tc_id = 3 AND result = '1-0';
```
![לפני שאילתא 1](שלב ב/update1_before.png)
![הרצה שאילתא 1](שלב ב/update1_run.png)
![אחרי שאילתא 1](שלב ב/update1_after.png)

**שאילתא 2: דחיית תאריכי סבבים ביום אחד עבור טורניר 1**
```sql
UPDATE Round SET scheduled_date = scheduled_date + 1 WHERE tournament_id = 1;
```
![לפני שאילתא 2](שלב ב/update2_before.png)
![הרצה שאילתא 2](שלב ב/update2_run.png)
![אחרי שאילתא 2](שלב ב/update2_after.png)

**שאילתא 3: קביעת תיקו למשחקי בזק ללא תוצאה**
```sql
UPDATE Game SET result = '1/2-1/2' WHERE result IS NULL AND tc_id IN (SELECT tc_id FROM TimeControl WHERE base_seconds < 180);
```
![לפני שאילתא 3](שלב ב/update3_before.png)
![הרצה שאילתא 3](שלב ב/update3_run.png)
![אחרי שאילתא 3](שלב ב/update3_after.png)

---

## 5. אילוצים (Constraints)

הוספנו 3 אילוצים חדשים למערכת. מטה מתוארת פקודת ההוספה ותמונת השגיאה המתקבלת כאשר מנסים להפר את האילוץ:

**1. אילוץ אורך מינימלי לשם משתמש (מעל 3 תווים):**
```sql
ALTER TABLE Player ADD CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3);
```
![שגיאת אילוץ 1](שלב ב/constraint1_error.png)

**2. אילוץ סטטוס חוקי בטבלת הרשמות:**
```sql
ALTER TABLE Registration ADD CONSTRAINT chk_reg_status CHECK (status IN ('Pending', 'Confirmed', 'Expired', 'Cancelled', 'Waiting'));
```
![שגיאת אילוץ 2](שלב ב/constraint2_error.png)

**3. זמן בסיס במשחק חייב להיות חיובי:**
```sql
ALTER TABLE TimeControl ADD CONSTRAINT chk_base_seconds CHECK (base_seconds > 0);
```
![שגיאת אילוץ 3](שלב ב/constraint3_error.png)

---

## 6. אינדקסים (Indexes)

הוספנו 3 אינדקסים וביצענו בדיקת זמני ריצה (Cost ב-Explain Plan) לפני ואחרי.

**1. אינדקס על שדה התוצאה בטבלת משחקים**
```sql
CREATE INDEX idx_game_result ON Game(result);
-- מוטיבציה ותועלת: שאילתות שמקבצות או סופרות ניצחונות/הפסדים (כמו שאילתא 6) דורשות גישה מהירה לשדה התוצאה. האינדקס חוסך סריקה מלאה של טבלת Game שהיא הטבלה הגדולה ביותר במערכת.
```
![לפני אינדקס 1](שלב ב/index1_before.png)
![אחרי אינדקס 1](שלב ב/index1_after.png)

**2. אינדקס על סטטוס הרשמות**
```sql
CREATE INDEX idx_registration_status ON Registration(status);
-- מוטיבציה ותועלת: מנהל המערכת ישתמש לעיתים קרובות בסינון נרשמים שממתינים לאישור.
```
![לפני אינדקס 2](שלב ב/index2_before.png)
![אחרי אינדקס 2](שלב ב/index2_after.png)

**3. אינדקס על תאריך התחלה בטורנירים**
```sql
CREATE INDEX idx_tournament_start_date ON Tournament(start_date);
-- מוטיבציה ותועלת: חיפוש וסינון טורנירים לפי שנים או תאריכים הוא נפוץ מאוד, והאינדקס מייעל משמעותית שאילתות מבוססות תאריך.
```
![לפני אינדקס 3](שלב ב/index3_before.png)
![אחרי אינדקס 3](שלב ב/index3_after.png)

---

## 7. Rollback ו-Commit

קובץ ה-`RollbackCommit.sql` מדגים שימוש בטרנזקציות.

**דוגמת Rollback:**
![לפני הטרנזקציה](שלב ב/rollback_before.png)
![במהלך הטרנזקציה](שלב ב/rollback_during.png)
![אחרי Rollback](שלב ב/rollback_after.png)

**דוגמת Commit:**
![לפני הטרנזקציה](שלב ב/commit_before.png)
![במהלך הטרנזקציה](שלב ב/commit_during.png)
![אחרי Commit](שלב ב/commit_after.png)
