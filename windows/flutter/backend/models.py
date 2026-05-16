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


# ---------------- UserGoal ----------------
class UserGoal(db.Model):
    __tablename__ = "user_goals"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False, unique=True)

    calories_goal = db.Column(db.Float, nullable=False)
    protein_goal = db.Column(db.Float, nullable=False)
    carbs_goal = db.Column(db.Float, nullable=False)
    fats_goal = db.Column(db.Float, nullable=False)
    is_custom = db.Column(db.Boolean, default=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

    user = db.relationship("User", backref="goal_settings")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "calories_goal": self.calories_goal,
            "protein_goal": self.protein_goal,
            "carbs_goal": self.carbs_goal,
            "fats_goal": self.fats_goal,
            "is_custom": self.is_custom,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
            "updated_at": (
                self.updated_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.updated_at
                else None
            ),
        }


# ---------------- NotificationSetting ----------------
class NotificationSetting(db.Model):
    __tablename__ = "notification_settings"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False, unique=True)

    permission_status = db.Column(db.String(30), default="not_determined")
    notifications_enabled = db.Column(db.Boolean, default=False)
    fcm_token = db.Column(db.String(500), nullable=True)
    meal_reminders = db.Column(db.Boolean, default=True)
    streak_reminders = db.Column(db.Boolean, default=True)
    water_reminders = db.Column(db.Boolean, default=False)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

    user = db.relationship("User", backref="notification_settings")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "permission_status": self.permission_status,
            "notifications_enabled": self.notifications_enabled,
            "fcm_token": self.fcm_token,
            "meal_reminders": self.meal_reminders,
            "streak_reminders": self.streak_reminders,
            "water_reminders": self.water_reminders,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
            "updated_at": (
                self.updated_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.updated_at
                else None
            ),
        }


# ---------------- NotificationLog ----------------
class NotificationLog(db.Model):
    __tablename__ = "notification_logs"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    title = db.Column(db.String(255), nullable=False)
    body = db.Column(db.Text, nullable=True)
    notification_type = db.Column(db.String(50), nullable=True)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship("User", backref="notification_logs")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "title": self.title,
            "body": self.body,
            "notification_type": self.notification_type,
            "is_read": self.is_read,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
        }


# ---------------- Payment ----------------
class Payment(db.Model):
    __tablename__ = "payments"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    plan_id = db.Column(db.Integer, db.ForeignKey("plans.id"), nullable=False)

    amount = db.Column(db.Float, nullable=False)
    currency = db.Column(db.String(10), default="USD")
    status = db.Column(db.String(30), default="pending")
    provider = db.Column(db.String(50), default="mock")
    provider_reference = db.Column(db.String(120), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    paid_at = db.Column(db.DateTime, nullable=True)

    user = db.relationship("User", backref="payments")
    plan = db.relationship("Plan")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "plan_id": self.plan_id,
            "plan": self.plan.to_dict() if self.plan else None,
            "amount": self.amount,
            "currency": self.currency,
            "status": self.status,
            "provider": self.provider,
            "provider_reference": self.provider_reference,
            "created_at": (
                self.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if self.created_at
                else None
            ),
            "paid_at": (
                self.paid_at.strftime("%Y-%m-%d %H:%M:%S") if self.paid_at else None
            ),
        }


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

    meal_type = db.Column(
        db.String(50), nullable=True
    )  # breakfast / lunch / dinner / snack
    scan_id = db.Column(db.String(120), nullable=True)
    food_item_id = db.Column(db.Integer, nullable=True)
    serving_name = db.Column(db.String(100), nullable=True)
    image_url = db.Column(db.String(700), nullable=True)
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
            "image_url": self.image_url,
            "log_time": (
                self.log_time.strftime("%Y-%m-%d %H:%M:%S") if self.log_time else None
            ),
            "ai_scan": self.ai_scan,
            "has_full_report": self.full_report is not None,
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
