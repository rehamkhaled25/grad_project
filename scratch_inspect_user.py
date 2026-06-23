import sqlite3
from datetime import datetime, date

db_path = "windows/flutter/backend/instance/calai.db"
conn = sqlite3.connect(db_path)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

# Get User ID 21 details
cursor.execute("SELECT * FROM users WHERE id = 21")
user = cursor.fetchone()
if user:
    print("--- USER 21 ---")
    for key in user.keys():
        print(f"{key}: {user[key]}")

# Calculate plan calories
if user:
    birthdate_value = str(user['birthdate'])
    birthdate_date = datetime.strptime(birthdate_value, "%Y-%m-%d").date()
    age = (date.today() - birthdate_date).days // 365
    weight = float(user['weight'])
    height = float(user['height'])
    goal_weight = float(user['goal_weight'])
    gender = user['gender'].lower()
    
    if gender == "male":
        bmr = 10 * weight + 6.25 * height - 5 * age + 5
    else:
        bmr = 10 * weight + 6.25 * height - 5 * age - 161
        
    maintenance_calories = bmr * 1.35
    weight_difference = goal_weight - weight
    
    if weight_difference < 0:
        calories = maintenance_calories - 500
    elif weight_difference > 0:
        calories = maintenance_calories + 400
    else:
        calories = maintenance_calories
        
    print(f"\nCalculated Plan Calories: {calories}")

# Get all food logs for User ID 21
cursor.execute("SELECT * FROM user_food_logs WHERE user_id = 21 ORDER BY log_time DESC")
logs = cursor.fetchall()
print("\n--- USER 21 FOOD LOGS ---")
for log in logs:
    print(f"Log ID: {log['id']}, Food: {log['food_name']}, Calories: {log['calories']}, LogTime: {log['log_time']}")

conn.close()
