import sqlite3
import os

db_paths = [
    r"c:\Users\'\grad_project\windows\flutter\backend\instance\calai.db",
    r"c:\Users\'\grad_project\instance\calai.db"
]

cols_to_add = [
    ("base_calories", "FLOAT DEFAULT 0"),
    ("base_protein", "FLOAT DEFAULT 0"),
    ("base_carbs", "FLOAT DEFAULT 0"),
    ("base_fats", "FLOAT DEFAULT 0"),
    ("portion_multiplier", "FLOAT DEFAULT 1.0")
]

for db_path in db_paths:
    if not os.path.exists(db_path):
        print(f"Database {db_path} does not exist, skipping.")
        continue
    
    print(f"Connecting to {db_path}...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get current columns
    cursor.execute("PRAGMA table_info(user_food_logs)")
    columns = [row[1] for row in cursor.fetchall()]
    print(f"Current columns in user_food_logs: {columns}")
    
    for col_name, col_type in cols_to_add:
        if col_name not in columns:
            try:
                print(f"Adding column {col_name} to {db_path}...")
                cursor.execute(f"ALTER TABLE user_food_logs ADD COLUMN {col_name} {col_type}")
                conn.commit()
                print(f"Successfully added {col_name}.")
            except Exception as e:
                print(f"Error adding {col_name}: {e}")
        else:
            print(f"Column {col_name} already exists.")
            
    conn.close()

print("Migration check complete.")
