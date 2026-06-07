## 4. מילון נתונים (Data Dictionary)

להלן פירוט של הטבלאות המרכזיות במערכת, תפקידן, סוגי הנתונים שנבחרו, ואילוצי שלמות המידע (Constraints).

### 1. טבלת `Game` (משחקים)
* **מטרה:** טבלה זו מרכזת את כלל נתוני המשחקים במערכת, והיא מיועדת להכיל היקף רשומות נרחב (Table Scale).
* **מבנה הטבלה:**
  * `game_id` (INT, Primary Key): מזהה ייחודי למשחק.
  * `white_player_id` (INT, Foreign Key): מקושר לטבלת Player.
  * `black_player_id` (INT, Foreign Key): מקושר לטבלת Player.
  * `tc_id` (INT, Foreign Key): מקושר לטבלת TimeControl.
  * `variant_id` (INT, Foreign Key): מקושר לטבלת GameVariant.
  * `round_id` (INT, Foreign Key): מקושר לטבלת Round. מאפשר ניהול משחקים במסגרת סיבוב בטורניר, אך נותר כאופציונלי על מנת לתמוך גם במשחקי ידידות חופשיים.
  * `result` (VARCHAR(10)): תוצאת המשחק. ממנה ניתן גם לגזור את חישובי הניקוד.
  * `start_date` (DATE, NOT NULL): תאריך תחילת המשחק.
  * `end_date` (DATE): תאריך סיום המשחק.
* **אילוצים מרכזיים:** מנגנון בקרה המחייב שזמן הסיום מאוחר או שווה לזמן ההתחלה. (`CONSTRAINT chk_game_dates CHECK (end_date >= start_date)`)

### 2. טבלת `Tournament` (תחרויות)
* **מטרה:** הגדרת תצורת טורנירים שחמט רשמיים, תזמונם, ושיוכם למועדון המארח.
* **מבנה הטבלה:**
  * `tournament_id` (INT, Primary Key): מזהה ייחודי לטורניר.
  * `club_id` (INT, Foreign Key): המועדון המארח, מקושר לטבלת Club.
  * `name` (VARCHAR(100), NOT NULL): שם הטורניר.
  * `registration_open_date` (DATE, NOT NULL): תאריך פתיחת ההרשמה.
  * `start_date` (DATE, NOT NULL): תאריך תחילת הטורניר.
  * `end_date` (DATE, NOT NULL): תאריך סיום הטורניר.
* **אילוצים מרכזיים:**
  * מנגנוני בקרה לתקינות התאריכים (פתיחת הרשמה קודמת להתחלה, התחלה קודמת לסיום).

### 3. טבלת `Registration` (רישום לתחרויות)
* **מטרה:** טבלה מקשרת לניהול רישום שחקנים לטורנירים השונים ומעקב אחר סטטוס הרישום.
* **מבנה הטבלה:**
  * `reg_id` (INT, Primary Key): מזהה ייחודי לרישום.
  * `tournament_id` (INT, Foreign Key): מקושר לטבלת Tournament.
  * `player_id` (INT, Foreign Key): מקושר לטבלת Player.
  * `registered_date` (DATE, NOT NULL): תאריך ביצוע הרישום בפועל.
  * `status` (VARCHAR(20)): סטטוס הרישום.

### 4. טבלת `Round` (סבבי תחרות)
* **מטרה:** חלוקת הטורניר לסבבי משחקים עוקבים על פני לוח הזמנים, אליהם ניתן לשייך משחקים רלוונטיים (מטבלת `Game`).
* **מבנה הטבלה:**
  * `round_id` (INT, Primary Key): מזהה ייחודי לסבב.
  * `tournament_id` (INT, Foreign Key): מקושר לטבלת Tournament.
  * `round_number` (INT, NOT NULL): המספר הסידורי של הסבב בטורניר.
  * `scheduled_date` (DATE, NOT NULL): תאריך היעד המתוכנן לקיום הסבב.

### 5. טבלת `TimeControl` (בקרת זמן - טבלת ייחוס)
* **מטרה:** קטלוג מרכזי המגדיר את סוגי בקרי הזמן התקניים במערכת, לצמצום כפילויות.
* **מבנה הטבלה:** `tc_id` (PK), `name`, `base_seconds`, `increment_seconds`.

### 6. טבלת `GameVariant` (וריאציות משחק - טבלת ייחוס)
* **מטרה:** קטלוג סוגי ווריאציות השחמט הנתמכות המהוות אפשרויות בחירה (כגון שחמט סטנדרטי או וריאציות מתקדמות).
* **מבנה הטבלה:** `variant_id` (PK), `name`.
