import streamlit as st
import psycopg2

st.set_page_config(
    page_title="Chess Tournament DB System",
    page_icon="♟️",
    layout="wide"
)

st.title("♟️ מערכת ניהול מועדוני ותחרויות שחמט")
st.markdown("""
ברוכים הבאים למערכת הניהול הגרפית של מסד הנתונים!
כאן תוכלו לבצע פעולות שונות כגון צפייה ועדכון רשומות, הרצת שאילתות מתקדמות, 
וכן הפעלת פונקציות ופרוצדורות מורכבות על בסיס הנתונים.

**אנא הזינו את פרטי ההתחברות למסד הנתונים PostgreSQL שלכם בטופס למטה:**
""")

# Initialize session state for DB credentials
if "db_creds" not in st.session_state:
    st.session_state.db_creds = {
        "host": "localhost",
        "port": "5432",
        "dbname": "postgres",
        "user": "postgres",
        "password": "",
        "connected": False
    }

# Connection Form
with st.form("db_connection_form"):
    st.subheader("התחברות למסד הנתונים")
    col1, col2 = st.columns(2)
    with col1:
        host = st.text_input("Host", value=st.session_state.db_creds["host"])
        dbname = st.text_input("Database Name", value=st.session_state.db_creds["dbname"])
        password = st.text_input("Password", type="password", value=st.session_state.db_creds["password"])
    with col2:
        port = st.text_input("Port", value=st.session_state.db_creds["port"])
        user = st.text_input("Username", value=st.session_state.db_creds["user"])
    
    submit_btn = st.form_submit_button("התחבר")

if submit_btn:
    st.session_state.db_creds.update({
        "host": host,
        "port": port,
        "dbname": dbname,
        "user": user,
        "password": password
    })
    
    # Test connection
    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=dbname,
            user=user,
            password=password
        )
        conn.close()
        st.session_state.db_creds["connected"] = True
        st.success("✅ החיבור למסד הנתונים בוצע בהצלחה! ניתן לעבור כעת לעמודים האחרים בתפריט הצד.")
    except Exception as e:
        st.session_state.db_creds["connected"] = False
        st.error(f"❌ שגיאה בהתחברות למסד הנתונים: {e}")

if st.session_state.db_creds["connected"]:
    st.info("מחובר כעת למסד הנתונים. השתמש בתפריט הצד (Sidebar) כדי לנווט במערכת.")
