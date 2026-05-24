import os
import random
from datetime import datetime, timedelta

def generate_manual_inserts():
    os.makedirs('Manual', exist_ok=True)
    with open('Manual/manual_inserts.sql', 'w', encoding='utf-8') as f:
        f.write("-- Manual Data Inserts\n\n")
        f.write("BEGIN;\n\n")
        
        # Clubs: 500
        f.write("-- Clubs\n")
        f.write("INSERT INTO Club (club_id, name) VALUES (1, 'Jerusalem Chess Club');\n")
        for i in range(2, 501):
            f.write(f"INSERT INTO Club (club_id, name) VALUES ({i}, 'Chess Club {i}');\n")
            
        # TimeControl: 500
        f.write("-- TimeControl\n")
        f.write("INSERT INTO TimeControl (tc_id, name, base_seconds, increment_seconds) VALUES (1, 'Blitz 3+2', 180, 2), (2, 'Rapid 10+5', 600, 5), (3, 'Classical 90+30', 5400, 30);\n")
        for i in range(4, 501):
            f.write(f"INSERT INTO TimeControl (tc_id, name, base_seconds, increment_seconds) VALUES ({i}, 'Custom {i}', {random.randint(60, 3600)}, {random.randint(0, 10)});\n")
            
        # GameVariant: 500
        f.write("-- GameVariant\n")
        f.write("INSERT INTO GameVariant (variant_id, name) VALUES (1, 'Standard'), (2, 'Chess960');\n")
        for i in range(3, 501):
            f.write(f"INSERT INTO GameVariant (variant_id, name) VALUES ({i}, 'Variant {i}');\n")
            
        f.write("\nCOMMIT;\n")

def generate_mockaroo_data():
    os.makedirs('mockarooFiles', exist_ok=True)
    with open('mockarooFiles/mockaroo_data.sql', 'w', encoding='utf-8') as f:
        f.write("-- Mockaroo Generated Data\n\n")
        f.write("BEGIN;\n\n")
        
        # Players: 20000
        f.write("-- Players\n")
        for i in range(1, 20001):
            f.write(f"INSERT INTO Player (player_id, username) VALUES ({i}, 'Player{i}_{random.randint(1000,9999)}');\n")
            
        # Tournaments: 500
        f.write("-- Tournaments\n")
        for i in range(1, 501):
            reg_date = f"2025-{random.randint(1,12):02d}-{random.randint(1,28):02d}"
            start_date = f"2026-{random.randint(1,12):02d}-{random.randint(1,28):02d}"
            end_date = start_date
            f.write(f"INSERT INTO Tournament (tournament_id, club_id, name, registration_open_date, start_date, end_date) VALUES ({i}, {random.randint(1, 500)}, 'Mockaroo Tourney {i}', '{reg_date}', '{start_date}', '{end_date}');\n")
            
        # Registrations: 20000 (Targeting 2nd table with 20K+ rows)
        f.write("-- Registrations\n")
        reg_id = 1
        for i in range(1, 20001):
            t_id = random.randint(1, 500)
            p_id = i # Each player registers to at least 1 tournament
            status = random.choice(['Registered', 'Withdrawn', 'Confirmed'])
            reg_d = f"2025-{random.randint(1,12):02d}-{random.randint(1,28):02d}"
            f.write(f"INSERT INTO Registration (reg_id, tournament_id, player_id, registered_date, status) VALUES ({reg_id}, {t_id}, {p_id}, '{reg_d}', '{status}');\n")
            reg_id += 1
            
        f.write("\nCOMMIT;\n")

if __name__ == '__main__':
    generate_manual_inserts()
    generate_mockaroo_data()
    print("Manual and Mockaroo data generated successfully.")
