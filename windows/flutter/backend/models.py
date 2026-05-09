from datetime import datetime
from extensions import db


# ---------------- User ----------------
class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(150), nullable=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    birthdate = db.Column(db.Date, nullable=True)  # غيرت من String لـ Date
    gender = db.Column(db.String(30), nullable=True)
    goal = db.Column(db.String(50), nullable=True)
    weight = db.Column(db.Float, nullable=True)
    height = db.Column(db.Float, nullable=True)
    goal_weight = db.Column(db.Float, nullable=True)
    allergies = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # علاقة بالـ Food Logs
    food_logs = db.relationship("UserFoodLog", backref="user", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "full_name": self.full_name,
            "email": self.email,
            "birthdate": (
                self.birthdate.strftime("%Y-%m-%d") if self.birthdate else None
            ),
            "gender": self.gender,
            "goal": self.goal,
            "weight": self.weight,
            "height": self.height,
            "goal_weight": self.goal_weight,
            "allergies": self.allergies.split(",") if self.allergies else [],
        }


# ---------------- Plan ----------------
class Plan(db.Model):
    __tablename__ = "plans"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    benefits = db.Column(db.String(500))  # نص مفصول بفواصل

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "price": self.price,
            "benefits": self.benefits.split(";") if self.benefits else [],
        }


# ---------------- UserPlan ----------------
class UserPlan(db.Model):
    __tablename__ = "user_plans"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    plan_id = db.Column(db.Integer, db.ForeignKey("plans.id"), nullable=False)
    start_date = db.Column(db.Date, default=datetime.utcnow)

    user = db.relationship("User", backref="plans")
    plan = db.relationship("Plan")


# ---------------- UserFoodLog ----------------
class UserFoodLog(db.Model):
    __tablename__ = "user_food_logs"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    food_name = db.Column(db.String(255), nullable=False)
    calories = db.Column(db.Float, default=0)
    protein = db.Column(db.Float, default=0)
    carbs = db.Column(db.Float, default=0)
    fats = db.Column(db.Float, default=0)

    serving_size = db.Column(db.Float, default=1)

    # New fields for Log Food page
    meal_type = db.Column(
        db.String(50), nullable=True
    )  # breakfast / lunch / dinner / snack
    scan_id = db.Column(db.String(120), nullable=True)  # لو الأكلة جاية من AI scan
    food_item_id = db.Column(db.Integer, nullable=True)  # بعدين مع Food Database
    serving_name = db.Column(db.String(100), nullable=True)
    full_report = db.Column(db.Text, nullable=True)

    log_time = db.Column(db.DateTime, default=datetime.utcnow)
    ai_scan = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "food_name": self.food_name,
            "calories": self.calories,
            "protein": self.protein,
            "carbs": self.carbs,
            "fats": self.fats,
            "serving_size": self.serving_size,
            "meal_type": self.meal_type,
            "scan_id": self.scan_id,
            "food_item_id": self.food_item_id,
            "serving_name": self.serving_name,
            "log_time": (
                self.log_time.strftime("%Y-%m-%d %H:%M:%S") if self.log_time else None
            ),
            "ai_scan": self.ai_scan,
        }

    # ---------------- FoodScan ----------------


class FoodScan(db.Model):
    __tablename__ = "food_scans"

    id = db.Column(db.Integer, primary_key=True)
    scan_id = db.Column(db.String(120), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    image_path = db.Column(db.String(500), nullable=False)
    context = db.Column(db.Text, nullable=True)

    meal_name = db.Column(db.String(255), nullable=True)
    calories = db.Column(db.Float, nullable=True)
    protein = db.Column(db.Float, nullable=True)
    carbs = db.Column(db.Float, nullable=True)
    fat = db.Column(db.Float, nullable=True)
    health_score = db.Column(db.Integer, nullable=True)

    full_report = db.Column(db.Text, nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    analyzed_at = db.Column(db.DateTime, nullable=True)

    def to_dict(self):
        return {
            "id": self.id,
            "scan_id": self.scan_id,
            "user_id": self.user_id,
            "image_path": self.image_path,
            "context": self.context,
            "meal_name": self.meal_name,
            "calories": self.calories,
            "protein": self.protein,
            "carbs": self.carbs,
            "fat": self.fat,
            "health_score": self.health_score,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
            "analyzed_at": (
                self.analyzed_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.analyzed_at
                else None
            ),
        }
