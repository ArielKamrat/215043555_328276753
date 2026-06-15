# תרשימים משולבים - שלב ג'

להלן קוד Mermaid המייצג את התרשימים המשולבים.
גיטהאב (GitHub) תומך בהצגת תרשימים אלו באופן אוטומטי. ניתן גם להעתיק את הקוד לאתר [Mermaid Live Editor](https://mermaid.live/) כדי לייצא אותם לתמונות.

> **טיפ חשוב לגבי ERDPlus:** אם ברצונכם להפיק את ה-DSD המדויק בתוך תוכנת **ERDPlus**, פשוט היכנסו לתוכנה, בחרו ב-**Import from SQL**, והדביקו לשם את התוכן של קובצי יצירת הטבלאות (כולל `Integrate.sql`). התוכנה תיצור את ה-DSD אוטומטית!

## 1. תרשים ישויות-קשרים משולב (ERD משותף)

```mermaid
erDiagram
    PLAYER ||--o{ CLUB_MEMBERSHIP : "has"
    PLAYER ||--o{ PLAYER_SUBSCRIPTION : "purchases"
    PLAYER ||--o{ LOGIN_LOG : "generates"
    PLAYER ||--o{ REGISTRATION : "registers for"
    PLAYER ||--o{ GAME : "plays as white"
    PLAYER ||--o{ GAME : "plays as black"
    PLAYER ||--o{ SOCIAL_CONNECTION : "connects"
    
    CLUB ||--o{ CLUB_MEMBERSHIP : "includes"
    CLUB ||--o{ TOURNAMENT : "hosts"
    
    TOURNAMENT ||--o{ REGISTRATION : "has"
    TOURNAMENT ||--o{ ROUND : "contains"
    
    ROUND ||--o{ GAME : "includes"
    
    TIME_CONTROL ||--o{ GAME : "defines time for"
    GAME_VARIANT ||--o{ GAME : "defines variant for"
    SUBSCRIPTION_TIER ||--o{ PLAYER_SUBSCRIPTION : "applied to"
    
    PLAYER {
        int player_id PK
        string username
        string email
        string status_code
        int rating_classical
        int rating_rapid
        int rating_blitz
    }
    
    CLUB {
        int club_id PK
        string club_name
        string country_code
        boolean is_official
    }
    
    TOURNAMENT {
        int tournament_id PK
        string name
        date start_date
        date end_date
    }
    
    GAME {
        int game_id PK
        string result
        date start_date
    }
```

## 2. תרשים סכמה משולבת לאחר האינטגרציה (DSD)

```mermaid
erDiagram
    PLAYER {
        int player_id PK
        varchar username
        varchar email
        varchar first_name
        varchar last_name
        char country_code
        varchar city
        varchar status_code FK
    }
    
    CLUB {
        int club_id PK
        varchar club_name
        char country_code
        varchar city
        boolean is_official
    }
    
    TOURNAMENT {
        int tournament_id PK
        int club_id FK
        varchar name
        date start_date
    }
    
    REGISTRATION {
        int reg_id PK
        int tournament_id FK
        int player_id FK
        date registered_date
    }
    
    GAME {
        int game_id PK
        int white_player_id FK
        int black_player_id FK
        int tc_id FK
        int round_id FK
        varchar result
    }
    
    CLUB_MEMBERSHIP {
        int membership_id PK
        int player_id FK
        int club_id FK
        varchar role_code FK
        int invited_by_player_id FK
    }
    
    LOGIN_LOG {
        int log_id PK
        int player_id FK
        varchar ip_address
        varchar login_status_code FK
        date login_date
    }
    
    PLAYER ||--o{ REGISTRATION : "player_id"
    PLAYER ||--o{ GAME : "white_player_id"
    PLAYER ||--o{ GAME : "black_player_id"
    PLAYER ||--o{ CLUB_MEMBERSHIP : "player_id"
    PLAYER ||--o{ LOGIN_LOG : "player_id"
    
    CLUB ||--o{ TOURNAMENT : "club_id"
    CLUB ||--o{ CLUB_MEMBERSHIP : "club_id"
    
    TOURNAMENT ||--o{ REGISTRATION : "tournament_id"
```
