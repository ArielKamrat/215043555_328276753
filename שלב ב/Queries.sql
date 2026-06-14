-- ==========================================
-- 4 שאילתות SELECT כפולות
-- ==========================================

-- שאילתא 1: מציאת שחקנים (שם ומזהה) שמעולם לא נרשמו לאף טורניר
-- דרך א': שימוש ב-NOT IN
SELECT username, player_id 
FROM Player 
WHERE player_id NOT IN (SELECT player_id FROM Registration WHERE player_id IS NOT NULL);

-- דרך ב': שימוש ב-LEFT JOIN ו-IS NULL (יותר יעיל בדרך כלל ממחיצות גדולות כי זה נמנע מסריקה מלאה של תת-השאילתא לכל שורה)
SELECT p.username, p.player_id 
FROM Player p 
LEFT JOIN Registration r ON p.player_id = r.player_id 
WHERE r.player_id IS NULL;


-- שאילתא 2: מציאת כמות המשחקים לשחקנים ששיחקו מעל 5 משחקים
-- דרך א': שימוש ב-GROUP BY ו-HAVING
SELECT p.username, COUNT(g.game_id) as total_games
FROM Player p
JOIN Game g ON p.player_id = g.white_player_id OR p.player_id = g.black_player_id
GROUP BY p.player_id, p.username
HAVING COUNT(g.game_id) > 5;

-- דרך ב': תת-שאילתא מסונכרנת (Correlated Subquery) ב-SELECT וב-WHERE (פחות יעיל משמעותית כי תת-השאילתא רצה עבור כל שחקן פעמיים)
SELECT p.username, (
    SELECT COUNT(*) FROM Game g WHERE g.white_player_id = p.player_id OR g.black_player_id = p.player_id
) as total_games
FROM Player p
WHERE (SELECT COUNT(*) FROM Game g WHERE g.white_player_id = p.player_id OR g.black_player_id = p.player_id) > 5;


-- שאילתא 3: מציאת שחקנים ששיחקו לפחות משחק אחד בסוג זמן מסוים (למשל tc_id = 1)
-- דרך א': שימוש ב-JOIN ו-DISTINCT (מחזיר 3 עמודות כדי לעמוד בדרישות)
SELECT DISTINCT p.username, p.player_id, tc.name as time_control_name
FROM Player p
JOIN Game g ON p.player_id = g.white_player_id OR p.player_id = g.black_player_id
JOIN TimeControl tc ON g.tc_id = tc.tc_id
WHERE tc.tc_id = 1;

-- דרך ב': שימוש ב-EXISTS (ה-EXISTS עוצר ברגע שהוא מוצא את המשחק הראשון, ולכן לרוב מהיר יותר מ-JOIN במקרים של כפילויות רבות)
SELECT p.username, p.player_id, (SELECT name FROM TimeControl WHERE tc_id = 1) as time_control_name
FROM Player p
WHERE EXISTS (
    SELECT 1 FROM Game g 
    WHERE (g.white_player_id = p.player_id OR g.black_player_id = p.player_id) 
    AND g.tc_id = 1
);


-- שאילתא 4: חיפוש משחקים שבהם השתתף שחקן מספר 1
-- דרך א': שימוש ב-OR
SELECT game_id, white_player_id, black_player_id, start_date
FROM Game
WHERE white_player_id = 1 OR black_player_id = 1;

-- דרך ב': שימוש ב-UNION (בחלק ממנועי בסיסי הנתונים שימוש ב-UNION מאפשר שימוש טוב יותר באינדקסים נפרדים לעמודת שחור ולעמודת לבן מאשר תנאי OR)
SELECT game_id, white_player_id, black_player_id, start_date
FROM Game WHERE white_player_id = 1
UNION
SELECT game_id, white_player_id, black_player_id, start_date
FROM Game WHERE black_player_id = 1;


-- ==========================================
-- 4 שאילתות SELECT רגילות
-- ==========================================

-- שאילתא 5: רשימת המשחקים ששוחקו במסגרת סבב מסוים (למשל סבב בטורניר שהיה בשנת 2025), עם שמות השחקנים
SELECT g.game_id, pw.username as white_player, pb.username as black_player, r.scheduled_date
FROM Game g
JOIN RoundResult rr ON g.game_id = rr.game_id
JOIN Round r ON rr.round_id = r.round_id
JOIN Player pw ON g.white_player_id = pw.player_id
JOIN Player pb ON g.black_player_id = pb.player_id
WHERE EXTRACT(YEAR FROM r.scheduled_date) = 2025
ORDER BY r.scheduled_date DESC;

-- שאילתא 6: סכימה של כמות ניצחונות ללבן מול שחור לכל סוג משחק (Variant)
SELECT v.name as variant_name, 
       SUM(CASE WHEN g.result = '1-0' THEN 1 ELSE 0 END) as white_wins,
       SUM(CASE WHEN g.result = '0-1' THEN 1 ELSE 0 END) as black_wins
FROM Game g
JOIN GameVariant v ON g.variant_id = v.variant_id
GROUP BY v.name;

-- שאילתא 7: הצגת המשחקים (ושמות השחקנים) בהם שיחקו יותר מ-30 מהלכים, מסודרים לפי כמות המהלכים
SELECT g.game_id, pw.username as white_player, pb.username as black_player, COUNT(m.move_id) as total_moves
FROM Game g
JOIN Player pw ON g.white_player_id = pw.player_id
JOIN Player pb ON g.black_player_id = pb.player_id
JOIN Move m ON g.game_id = m.game_id
GROUP BY g.game_id, pw.username, pb.username
HAVING COUNT(m.move_id) > 30
ORDER BY total_moves DESC;

-- שאילתא 8: מציאת טורנירים שיש להם מועדון אבל עדיין לא הוגדרו להם סבבים (Rounds)
SELECT t.tournament_id, t.name, t.start_date
FROM Tournament t
JOIN Club c ON t.club_id = c.club_id
LEFT JOIN Round rnd ON t.tournament_id = rnd.tournament_id
WHERE rnd.round_id IS NULL;


-- ==========================================
-- 3 שאילתות DELETE
-- ==========================================

-- 1. מחיקת משחקים שנקבעו לעתיד וטרם שוחקו (התאריך שלהם גדול מהתאריך של היום)
DELETE FROM Game WHERE start_date > CURRENT_DATE AND result IS NULL;

-- 2. מחיקת כל הטורנירים שהסתיימו לפני שנת 2022 כדי לנקות דאטה ישן
DELETE FROM Tournament WHERE EXTRACT(YEAR FROM end_date) < 2022;

-- 3. מחיקת סבבים שנקבעו בטעות לתאריך שקודם לתאריך תחילת הטורניר שלהם
DELETE FROM Round 
WHERE scheduled_date < (SELECT start_date FROM Tournament t WHERE t.tournament_id = Round.tournament_id);


-- ==========================================
-- 3 שאילתות UPDATE
-- ==========================================

-- 1. עדכון מזהה ה-tc_id של כל המשחקים מסוג מסוים
UPDATE Game 
SET tc_id = 2 
WHERE tc_id = 3 AND result = '1-0';

-- 2. דחיית תאריכי הסבבים ביום אחד עבור הטורניר עם המזהה 1
UPDATE Round 
SET scheduled_date = scheduled_date + 1 
WHERE tournament_id = 1;

-- 3. קביעת תוצאת תיקו אוטומטית למשחקי בזק (מעט שניות) שאין להם תוצאה עדיין
UPDATE Game 
SET result = '1/2-1/2' 
WHERE result IS NULL AND tc_id IN (SELECT tc_id FROM TimeControl WHERE base_seconds < 180);
