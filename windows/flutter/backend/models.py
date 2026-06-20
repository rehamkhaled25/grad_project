from datetime import datetime
from extensions import db


# ---------------- User ----------------
class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(150), nullable=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    birthdate = db.Column(db.Date, nullable=True)
    gender = db.Column(db.String(30), nullable=True)
    goal = db.Column(db.String(50), nullable=True)
    weight = db.Column(db.Float, nullable=True)
    height = db.Column(db.Float, nullable=True)
    goal_weight = db.Column(db.Float, nullable=True)
    allergies = db.Column(db.Text, nullable=True)
    profile_image = db.Column(db.String(500), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

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
            "profile_image": self.profile_image,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
        }


# ---------------- Plan ----------------
class Plan(db.Model):
    __tablename__ = "plans"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    benefits = db.Column(db.String(500))

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

    # Base nutritional values
    base_calories = db.Column(db.Float, default=0)
    base_protein = db.Column(db.Float, default=0)
    base_carbs = db.Column(db.Float, default=0)
    base_fats = db.Column(db.Float, default=0)
    portion_multiplier = db.Column(db.Float, default=1.0)

    serving_size = db.Column(db.Float, default=1)

    meal_type = db.Column(
        db.String(50), nullable=True
    )  # breakfast / lunch / dinner / snack
    scan_id = db.Column(db.String(120), nullable=True)
    food_item_id = db.Column(db.Integer, nullable=True)
    serving_name = db.Column(db.String(100), nullable=True)
    image_url = db.Column(db.String(500), nullable=True)
    full_report = db.Column(db.Text, nullable=True)

    log_time = db.Column(db.DateTime, default=datetime.utcnow)
    ai_scan = db.Column(db.Boolean, default=False)

    def to_dict(self):
        gi = 0
        gl = 0
        gi_rating = ""
        if self.full_report:
            try:
                import json
                report = json.loads(self.full_report)
                gi = report.get("glycemic_index") or report.get("item_gi") or 0
                gl = report.get("total_gl") or report.get("glycemic_load") or 0
                gi_rating = report.get("glycemic_index_rating") or report.get("gl_category") or ""
            except Exception:
                pass

        return {
            "id": self.id,
            "user_id": self.user_id,
            "food_name": self.food_name,
            "calories": self.calories,
            "protein": self.protein,
            "carbs": self.carbs,
            "fats": self.fats,
            "base_calories": self.base_calories,
            "base_protein": self.base_protein,
            "base_carbs": self.base_carbs,
            "base_fats": self.base_fats,
            "portion_multiplier": self.portion_multiplier,
            "serving_size": self.serving_size,
            "meal_type": self.meal_type,
            "scan_id": self.scan_id,
            "food_item_id": self.food_item_id,
            "serving_name": self.serving_name,
            "image_url": self.image_url,
            "log_time": (
                self.log_time.strftime("%Y-%m-%d %H:%M:%S") if self.log_time else None
            ),
            "ai_scan": self.ai_scan,
            "has_full_report": self.full_report is not None,
            "glycemic_index": gi,
            "glycemic_load": gl,
            "glycemic_index_rating": gi_rating,
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
            "fats": self.fat,
            "health_score": self.health_score,
            "has_full_report": self.full_report is not None,
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


# ---------------- FoodItem ----------------
class FoodItem(db.Model):
    __tablename__ = "food_items"

    id = db.Column(db.Integer, primary_key=True)
    food_name = db.Column(db.String(255), nullable=False)
    brand = db.Column(db.String(255), nullable=True)
    category = db.Column(db.String(100), nullable=True)

    calories = db.Column(db.Float, default=0)
    protein = db.Column(db.Float, default=0)
    carbs = db.Column(db.Float, default=0)
    fats = db.Column(db.Float, default=0)

    image_url = db.Column(db.String(500), nullable=True)
    source = db.Column(db.String(50), default="local_database")

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    servings = db.relationship(
        "FoodServing",
        backref="food_item",
        lazy=True,
        cascade="all, delete-orphan",
    )

    def to_dict(self):
        return {
            "id": self.id,
            "food_name": self.food_name,
            "brand": self.brand,
            "category": self.category,
            "calories": self.calories,
            "protein": self.protein,
            "carbs": self.carbs,
            "fats": self.fats,
            "image_url": self.image_url,
            "source": self.source,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
        }


# ---------------- FoodServing ----------------
class FoodServing(db.Model):
    __tablename__ = "food_servings"

    id = db.Column(db.Integer, primary_key=True)
    food_item_id = db.Column(db.Integer, db.ForeignKey("food_items.id"), nullable=False)

    serving_name = db.Column(db.String(100), nullable=False)
    grams = db.Column(db.Float, nullable=True)

    calories = db.Column(db.Float, default=0)
    protein = db.Column(db.Float, default=0)
    carbs = db.Column(db.Float, default=0)
    fats = db.Column(db.Float, default=0)

    def to_dict(self):
        return {
            "id": self.id,
            "food_item_id": self.food_item_id,
            "serving_name": self.serving_name,
            "grams": self.grams,
            "calories": self.calories,
            "protein": self.protein,
            "carbs": self.carbs,
            "fats": self.fats,
        }


# ---------------- UserWeightLog ----------------
class UserWeightLog(db.Model):
    __tablename__ = "user_weight_logs"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    weight = db.Column(db.Float, nullable=False)
    log_date = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "weight": self.weight,
            "log_date": self.log_date.strftime("%Y-%m-%d"),
            "created_at": self.created_at.strftime("%Y-%m-%d %H:%M:%S") if self.created_at else None
        }

