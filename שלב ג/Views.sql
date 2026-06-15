-- ======================================================================================
-- Views.sql
-- שלב ג: יצירת מבטים ושאילתות על המבטים.
-- ======================================================================================

-- ==========================================
-- מבט 1 מנקודת המבט של המערכת המקורית שלנו (תחרויות)
-- מציג מידע על תחרויות כולל שם המועדון המארח ומספר השחקנים שנרשמו אליו.
-- ==========================================
CREATE VIEW v_tournament_details AS
SELECT 
    t.tournament_id,
    t.name AS tournament_name,
    c.club_name AS host_club_name,
    t.start_date,
    t.end_date,
    COUNT(r.player_id) AS registered_players_count
FROM 
    Tournament t
JOIN 
    Club c ON t.club_id = c.club_id
LEFT JOIN 
    Registration r ON t.tournament_id = r.tournament_id
GROUP BY 
    t.tournament_id, t.name, c.club_name, t.start_date, t.end_date;

-- שאילתה 1 על מבט 1: הצגת התחרויות שיתקיימו (או התקיימו) בשנת 2024 ושנרשמו אליהן לפחות 10 שחקנים
-- SELECT * FROM v_tournament_details 
-- WHERE EXTRACT(YEAR FROM start_date) = 2024 AND registered_players_count >= 10;

-- שאילתה 2 על מבט 1: מהו ממוצע השחקנים הרשומים לתחרות עבור כל מועדון מארח (רק מועדונים עם תחרויות)
-- SELECT host_club_name, AVG(registered_players_count) AS avg_players_per_tournament 
-- FROM v_tournament_details 
-- GROUP BY host_club_name
-- ORDER BY avg_players_per_tournament DESC;


-- ==========================================
-- מבט 2 מנקודת המבט של המערכת שהתקבלה (משתמשים ומועדונים)
-- מציג את הפרופיל המלא של שחקן כולל המועדון שהוא חבר בו ותפקידו במועדון.
-- ==========================================
CREATE VIEW v_player_club_profiles AS
SELECT 
    p.player_id,
    p.username,
    p.rating_classical,
    p.rating_blitz,
    cm.role_code AS club_role,
    c.club_name,
    c.is_official
FROM 
    Player p
JOIN 
    club_membership cm ON p.player_id = cm.player_id
JOIN 
    Club c ON cm.club_id = c.club_id
WHERE 
    cm.left_date IS NULL; -- רק חברויות פעילות במועדון

-- שאילתה 1 על מבט 2: מצא שחקנים בעלי דירוג בליץ גבוה מ-2000 שהם מנהלים (admin/owner) במועדון רשמי
-- SELECT username, rating_blitz, club_name, club_role
-- FROM v_player_club_profiles
-- WHERE rating_blitz > 2000 
--   AND is_official = TRUE 
--   AND club_role IN ('admin', 'owner');

-- שאילתה 2 על מבט 2: רשימת 5 המועדונים (הרשמיים) המובילים לפי ממוצע דירוג קלאסי של חברי המועדון שלהם
-- SELECT club_name, ROUND(AVG(rating_classical), 2) AS avg_classical_rating, COUNT(player_id) AS total_members
-- FROM v_player_club_profiles
-- WHERE is_official = TRUE
-- GROUP BY club_name
-- ORDER BY avg_classical_rating DESC
-- LIMIT 5;
