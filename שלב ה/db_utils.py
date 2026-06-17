import psycopg2
import streamlit as st
import pandas as pd

def get_connection():
    """
    Returns a psycopg2 connection using connection parameters stored in Streamlit's session state.
    """
    if "db_creds" not in st.session_state or not st.session_state.db_creds["connected"]:
        st.warning("Please connect to the database from the Home page first.")
        st.stop()
        
    creds = st.session_state.db_creds
    try:
        conn = psycopg2.connect(
            host=creds["host"],
            port=creds["port"],
            database=creds["dbname"],
            user=creds["user"],
            password=creds["password"]
        )
        return conn
    except Exception as e:
        st.error(f"Failed to connect to database: {e}")
        st.stop()

def run_query(query, params=None):
    """
    Executes a SELECT query and returns the results as a pandas DataFrame.
    """
    conn = get_connection()
    try:
        if params:
            df = pd.read_sql_query(query, conn, params=params)
        else:
            df = pd.read_sql_query(query, conn)
        return df
    except Exception as e:
        st.error(f"Error executing query: {e}")
        return None
    finally:
        conn.close()

def execute_dml(query, params=None):
    """
    Executes an INSERT, UPDATE, or DELETE query and commits it.
    Returns True on success, False on failure.
    """
    conn = get_connection()
    try:
        cur = conn.cursor()
        if params:
            cur.execute(query, params)
        else:
            cur.execute(query)
        conn.commit()
        cur.close()
        return True
    except Exception as e:
        st.error(f"Error executing DML: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def execute_procedure(query, params=None):
    """
    Executes a stored procedure that might contain transaction control (COMMIT/ROLLBACK).
    Uses autocommit mode.
    """
    conn = get_connection()
    try:
        conn.autocommit = True
        cur = conn.cursor()
        if params:
            cur.execute(query, params)
        else:
            cur.execute(query)
        cur.close()
        return True
    except Exception as e:
        st.error(f"Error executing Procedure: {e}")
        return False
    finally:
        conn.close()

