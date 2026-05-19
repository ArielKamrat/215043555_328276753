import random
from datetime import datetime, timedelta
from faker import Faker
import chess

fake = Faker()

# הגדרת כמויות (כדי להגיע ל-20K מהלכים מספיק ליצור 1000 משחקים, בממוצע 30 מהלכים למשחק)
NUM_PLAYERS = 500
NUM_TOURNAMENTS = 100
NUM_ROUNDS = 500
NUM_GAMES = 1000

def generate_sql():
    with open('insertTables.sql', 'w', encoding='utf-8') as f:
        f.write("-- SQL Data Generation Script\n\n")
        f.write("BEGIN;\n\n") # --- התחלת טרנזקציה אחת גדולה (מאיץ פי 1000) ---

        # 1. Player & Club 
        f.write("-- Players\n")
        for i in range(1, NUM_PLAYERS + 1):
            # טיפול בשמות עם גרשיים כדי שלא ישברו את ה-SQL
            safe_username = fake.user_name().replace("'", "''")
            f.write(f"INSERT INTO Player (player_id, username) VALUES ({i}, '{safe_username}');\n")
        
        f.write("-- Clubs\n")
        f.write("INSERT INTO Club (club_id, name) VALUES (1, 'Jerusalem Chess Club');\n")
        
        # 2. TimeControl & GameVariant
        f.write("-- TimeControl\n")
        tc_data = [(1, 'Blitz 3+2', 180, 2), (2, 'Rapid 10+5', 600, 5), (3, 'Classical 90+30', 5400, 30)]
        for tc in tc_data:
            f.write(f"INSERT INTO TimeControl (tc_id, name, base_seconds, increment_seconds) VALUES {tc};\n")
            
        f.write("-- GameVariant\n")
        f.write("INSERT INTO GameVariant (variant_id, name) VALUES (1, 'Standard'), (2, 'Chess960');\n")

        # 3. Tournament
        f.write("-- Tournament\n")
        for i in range(1, NUM_TOURNAMENTS + 1):
            start = fake.date_between(start_date='-1y', end_date='today')
            reg = start - timedelta(days=14)
            end = start + timedelta(days=random.randint(1, 5))
            f.write(f"INSERT INTO Tournament (tournament_id, club_id, name, registration_open_date, start_date, end_date) VALUES ({i}, 1, 'Tournament {i}', '{reg}', '{start}', '{end}');\n")

        # 4. Round
        f.write("-- Round\n")
        for i in range(1, NUM_ROUNDS + 1):
            t_id = random.randint(1, NUM_TOURNAMENTS)
            s_date = fake.date_between(start_date='-1y', end_date='today')
            f.write(f"INSERT INTO Round (round_id, tournament_id, round_number, scheduled_date) VALUES ({i}, {t_id}, {random.randint(1, 5)}, '{s_date}');\n")

        # 5. Game & Move & RoundResult 
        f.write("-- Game, RoundResult, Move\n")
        move_id = 1
        result_id = 1
        
        for game_id in range(1, NUM_GAMES + 1):
            w_player = random.randint(1, NUM_PLAYERS)
            b_player = random.randint(1, NUM_PLAYERS)
            while b_player == w_player:
                b_player = random.randint(1, NUM_PLAYERS)
                
            res = random.choice(['1-0', '0-1', '1/2-1/2'])
            start_date = fake.date_between(start_date='-1y', end_date='today')
            end_date = start_date 
            
            f.write(f"INSERT INTO Game (game_id, white_player_id, black_player_id, tc_id, variant_id, result, start_date, end_date) VALUES ({game_id}, {w_player}, {b_player}, {random.randint(1,3)}, 1, '{res}', '{start_date}', '{end_date}');\n")
            
            w_pts = 1 if res == '1-0' else (0.5 if res == '1/2-1/2' else 0)
            b_pts = 1 if res == '0-1' else (0.5 if res == '1/2-1/2' else 0)
            f.write(f"INSERT INTO RoundResult (result_id, round_id, game_id, white_points, black_points) VALUES ({result_id}, {random.randint(1, NUM_ROUNDS)}, {game_id}, {w_pts}, {b_pts});\n")
            result_id += 1

            board = chess.Board()
            move_num = 1
            
            while not board.is_game_over() and move_num <= random.randint(20, 60):
                legal_moves = list(board.legal_moves)
                if not legal_moves:
                    break
                move = random.choice(legal_moves)
                
                pgn = board.san(move).replace("'", "''") 
                color = "White" if board.turn == chess.WHITE else "Black"
                eval_cp = random.randint(-300, 300)
                time_spent = random.randint(1000, 15000)
                
                board.push(move)
                
                f.write(f"INSERT INTO Move (move_id, game_id, move_number, color, pgn_notation, move_timestamp, time_spent_ms, engine_eval_cp) VALUES ({move_id}, {game_id}, {move_num}, '{color}', '{pgn}', '{start_date}', {time_spent}, {eval_cp});\n")
                
                move_id += 1
                if color == "Black":
                    move_num += 1

        f.write("\nCOMMIT;\n") # --- סגירת טרנזקציה ושמירה לדיסק ---

    print(f"Done! Created insertTables.sql with {move_id-1} Moves.")

if __name__ == '__main__':
    generate_sql()
