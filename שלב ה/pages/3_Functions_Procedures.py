import streamlit as st
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import db_utils

st.set_page_config(page_title="Functions & Procedures", page_icon="⚙️", layout="wide")
st.title("⚙️ הפעלת פונקציות ופרוצדורות")

if "db_creds" not in st.session_state or not st.session_state.db_creds.get("connected"):
    st.warning("אנא התחברו למסד הנתונים ממסך הבית קודם.")
    st.stop()

st.markdown("כאן ניתן להריץ את התוכניות שפותחו בשלב ד' ישירות מבסיס הנתונים.")

col1, col2 = st.columns(2)

with col1:
    st.subheader("פונקציה: חישוב אחוזי פעילות בטורניר")
    st.markdown("מחזירה את אחוז השחקנים הרשומים בטורניר ששיחקו בו לפחות משחק אחד. מבוססת על הפונקציה `fn_calculate_tournament_activity`.")
    with st.form("func_activity"):
        t_id = st.number_input("מזהה טורניר (Tournament ID):", min_value=1, step=1)
        if st.form_submit_button("חשב אחוז פעילות"):
            query = "SELECT fn_calculate_tournament_activity(%s) as activity_percentage"
            df = db_utils.run_query(query, (t_id,))
            if df is not None and not df.empty:
                val = df.iloc[0]['activity_percentage']
                if val == -1:
                    st.error("התרחשה שגיאה בחישוב. ייתכן והטורניר אינו קיים.")
                else:
                    st.success(f"אחוז הפעילות בטורניר {t_id} הוא: {val}%")

with col2:
    st.subheader("פרוצדורה: סגירת טורניר ועדכון ניקוד")
    st.markdown("סוגרת את הטורניר ומחשבת את הניקוד המצטבר של השחקנים על בסיס משחקיהם. מבוססת על הפרוצדורה `pr_close_tournament_and_score`.")
    with st.form("proc_close_t"):
        close_t_id = st.number_input("מזהה טורניר לסגירה (Tournament ID):", min_value=1, step=1)
        if st.form_submit_button("סגור טורניר ועדכן ניקוד"):
            # Procedures need to be CALLed, using execute_procedure to avoid transaction blocks
            query = "CALL pr_close_tournament_and_score(%s)"
            if db_utils.execute_procedure(query, (close_t_id,)):
                st.success(f"טורניר {close_t_id} נסגר בהצלחה והניקוד עודכן!")
