import sqlite3
from datetime import datetime, timedelta

db_path = "windows/flutter/backend/instance/calai.db"
conn = sqlite3.connect(db_path)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

user_id = 21
date_str = "2026-06-24"
yesterday = datetime.strptime(date_str, "%Y-%m-%d") - timedelta(days=1)
yesterday_str = yesterday.strftime("%Y-%m-%d")

# 1. Fetch yesterday's consumed calories
start = datetime.combine(yesterday.date(), datetime.min.time())
end = datetime.combine(yesterday.date(), datetime.max.time())
cursor.execute("SELECT SUM(calories) as total_cal FROM user_food_logs WHERE user_id = ? AND log_time >= ? AND log_time <= ?", (user_id, start, end))
row = cursor.fetchone()
yesterday_consumed = row['total_cal'] or 0.0

# 2. Fetch base plan calories
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
user = cursor.fetchone()
birthdate_date = datetime.strptime(user['birthdate'], "%Y-%m-%d").date()
age = (datetime.now().date() - birthdate_date).days // 365
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
    base_goal_calories = maintenance_calories - 500
elif weight_difference > 0:
    base_goal_calories = maintenance_calories + 400
else:
    base_goal_calories = maintenance_calories

# 3. Rollover calculation
rollover = 0.0
if yesterday_consumed > 0:
    rollover = (base_goal_calories + 0.0) - yesterday_consumed

goal_calories = base_goal_calories + rollover

print(f"Date: {date_str}")
print(f"Yesterday Date: {yesterday_str}")
print(f"Yesterday Consumed: {yesterday_consumed} kcal")
print(f"Base Goal Calories: {base_goal_calories} kcal")
print(f"Rollover: {rollover} kcal")
print(f"Today's Goal Calories (with Rollover): {goal_calories} kcal")

conn.close()
