import streamlit as st
import pandas as pd
import sys
import os

# הוספת התיקייה הראשית לנתיב כדי שנוכל לייבא את db_utils
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import db_utils

st.set_page_config(page_title="CRUD Operations", page_icon="📝", layout="wide")
st.title("📝 פעולות CRUD על טבלאות")

if "db_creds" not in st.session_state or not st.session_state.db_creds.get("connected"):
    st.warning("אנא התחברו למסד הנתונים ממסך הבית קודם.")
    st.stop()

# רשימת טבלאות מרכזיות במערכת לצורך ה-CRUD
TABLES = {
    "Player": {"pk": "player_id", "display_query": "SELECT player_id, username, rating_classical, email FROM Player"},
    "Club": {"pk": "club_id", "display_query": "SELECT club_id, club_name, city, is_official FROM Club"},
    "Tournament": {"pk": "tournament_id", "display_query": "SELECT t.tournament_id, t.name, c.club_name, t.start_date, t.status FROM Tournament t LEFT JOIN Club c ON t.club_id = c.club_id"},
    "Game": {"pk": "game_id", "display_query": "SELECT g.game_id, pw.username as white_player, pb.username as black_player, g.result, g.start_date FROM Game g JOIN Player pw ON g.white_player_id = pw.player_id JOIN Player pb ON g.black_player_id = pb.player_id"},
    "Registration": {"pk": "reg_id", "display_query": "SELECT r.reg_id, p.username as player_name, t.name as tournament_name, r.registered_date, r.status FROM Registration r JOIN Player p ON r.player_id = p.player_id JOIN Tournament t ON r.tournament_id = t.tournament_id"},
    "Round": {"pk": "round_id", "display_query": "SELECT rnd.round_id, t.name as tournament_name, rnd.round_number, rnd.scheduled_date FROM Round rnd JOIN Tournament t ON rnd.tournament_id = t.tournament_id"},
    "TimeControl": {"pk": "tc_id", "display_query": "SELECT tc_id, name, base_seconds, increment_seconds FROM TimeControl"},
    "GameVariant": {"pk": "variant_id", "display_query": "SELECT variant_id, name FROM GameVariant"}
}

selected_table = st.selectbox("בחר טבלה לפעולה:", list(TABLES.keys()))
pk_col = TABLES[selected_table]["pk"]

st.divider()

tab_read, tab_insert, tab_update, tab_delete = st.tabs(["קריאה (Read)", "הכנסה (Create)", "עדכון (Update)", "מחיקה (Delete)"])

# --- READ ---
with tab_read:
    st.subheader(f"נתוני טבלת {selected_table}")
    st.markdown("*שימו לב: מפתחות זרים מוחלפים בשמות רלוונטיים בתצוגה זו לנוחות המשתמש.*")
    df = db_utils.run_query(TABLES[selected_table]["display_query"])
    if df is not None and not df.empty:
        st.dataframe(df, use_container_width=True)
    else:
        st.info("אין נתונים בטבלה זו או שגיאה בשליפה.")

# Helper to get actual table columns for form generation
def get_columns(table_name):
    query = f"SELECT column_name, data_type FROM information_schema.columns WHERE table_name = LOWER('{table_name}')"
    return db_utils.run_query(query)

# --- CREATE ---
with tab_insert:
    st.subheader(f"הוספת רשומה חדשה לטבלת {selected_table}")
    cols_df = get_columns(selected_table)
    if cols_df is not None:
        with st.form(f"insert_form_{selected_table}"):
            insert_data = {}
            for _, row in cols_df.iterrows():
                col_name = row['column_name']
                insert_data[col_name] = st.text_input(f"{col_name} ({row['data_type']})")
            
            if st.form_submit_button("הוסף רשומה"):
                # Filter out empty fields
                insert_data = {k: v for k, v in insert_data.items() if v.strip() != ""}
                if insert_data:
                    cols = ", ".join(insert_data.keys())
                    vals_placeholders = ", ".join([f"%({k})s" for k in insert_data.keys()])
                    query = f"INSERT INTO {selected_table} ({cols}) VALUES ({vals_placeholders})"
                    if db_utils.execute_dml(query, insert_data):
                        st.success("הרשומה נוספה בהצלחה! רענן את הדף כדי לראות שינויים.")
                else:
                    st.warning("נא למלא לפחות שדה אחד.")

# --- UPDATE ---
with tab_update:
    st.subheader(f"עדכון רשומה בטבלת {selected_table}")
    st.markdown(f"הזן את ה-{pk_col} של הרשומה אותה תרצה לעדכן ולחץ אנטר (או לחץ מחוץ לתיבה).")
    
    update_id = st.text_input(f"הזן {pk_col} לשליפה:")
    if update_id:
        record_df = db_utils.run_query(f"SELECT * FROM {selected_table} WHERE {pk_col} = %s", (update_id,))
        if record_df is not None and not record_df.empty:
            st.success("רשומה נמצאה! עדכן את השדות הנדרשים:")
            record = record_df.iloc[0].to_dict()
            with st.form(f"update_form_{selected_table}"):
                update_data = {}
                for col_name, current_val in record.items():
                    if col_name == pk_col:
                        st.text_input(f"{col_name} (Primary Key - לא ניתן לשינוי)", value=str(current_val), disabled=True)
                    else:
                        val = "" if pd.isna(current_val) else str(current_val)
                        update_data[col_name] = st.text_input(f"{col_name}", value=val)
                
                if st.form_submit_button("שמור שינויים"):
                    set_clause = ", ".join([f"{k} = %({k})s" for k in update_data.keys()])
                    query = f"UPDATE {selected_table} SET {set_clause} WHERE {pk_col} = %(pk_val)s"
                    update_data["pk_val"] = update_id
                    if db_utils.execute_dml(query, update_data):
                        st.success("הרשומה עודכנה בהצלחה!")
        else:
            st.warning("לא נמצאה רשומה עם המפתח שהוזן.")

# --- DELETE ---
with tab_delete:
    st.subheader(f"מחיקת רשומה מטבלת {selected_table}")
    with st.form(f"delete_form_{selected_table}"):
        delete_id = st.text_input(f"הזן {pk_col} למחיקה:")
        if st.form_submit_button("מחק רשומה", type="primary"):
            if delete_id:
                query = f"DELETE FROM {selected_table} WHERE {pk_col} = %s"
                if db_utils.execute_dml(query, (delete_id,)):
                    st.success("הרשומה נמחקה בהצלחה (אם הייתה קיימת).")
            else:
                st.warning("נא להזין מזהה למחיקה.")
