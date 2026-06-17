import streamlit as st
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import db_utils

st.set_page_config(page_title="Queries", page_icon="🔍", layout="wide")
st.title("🔍 הפעלת שאילתות מתקדמות")

if "db_creds" not in st.session_state or not st.session_state.db_creds.get("connected"):
    st.warning("אנא התחברו למסד הנתונים ממסך הבית קודם.")
    st.stop()

st.markdown("מסך זה מאפשר להריץ שאילתות מורכבות משלב ב' של הפרויקט.")

# שאילתא 1
st.subheader("שאילתא 1: שחקנים שמעולם לא נרשמו לאף טורניר")
st.markdown("""
שאילתא זו משתמשת ב-LEFT JOIN כדי למצוא שחקנים (מטבלת Player) שאין להם אף רשומה מקבילה בטבלת Registration.
""")
q1 = """
SELECT p.username, p.player_id 
FROM Player p 
LEFT JOIN Registration r ON p.player_id = r.player_id 
WHERE r.player_id IS NULL;
"""
if st.button("הרץ שאילתא 1"):
    df1 = db_utils.run_query(q1)
    if df1 is not None:
        st.dataframe(df1, use_container_width=True)
        st.caption(f"נמצאו {len(df1)} תוצאות.")

st.divider()

# שאילתא 2 (מספר 8 במקור)
st.subheader("שאילתא 2: טורנירים שעדיין לא הוגדרו להם סבבים (Rounds)")
st.markdown("""
שאילתא זו משלבת נתוני טורנירים ומועדונים, ומחפשת באמצעות LEFT JOIN איזה מהטורנירים לא מכיל אף סבב מתוכנן בטבלת Round.
""")
q2 = """
SELECT t.tournament_id, t.name as tournament_name, c.club_name, t.start_date
FROM Tournament t
JOIN Club c ON t.club_id = c.club_id
LEFT JOIN Round rnd ON t.tournament_id = rnd.tournament_id
WHERE rnd.round_id IS NULL;
"""
if st.button("הרץ שאילתא 2"):
    df2 = db_utils.run_query(q2)
    if df2 is not None:
        st.dataframe(df2, use_container_width=True)
        st.caption(f"נמצאו {len(df2)} תוצאות.")
