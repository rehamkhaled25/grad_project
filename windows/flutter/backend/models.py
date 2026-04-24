from datetime import datetime
from extensions import db

class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(150), nullable=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    birthdate = db.Column(db.Date, nullable=True)  # غيرت من String لـ Date عشان نقدر نحسب العمر بسهولة
    gender = db.Column(db.String(30), nullable=True)
    goal = db.Column(db.String(50), nullable=True)
    weight = db.Column(db.Float, nullable=True)
    height = db.Column(db.Float, nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "full_name": self.full_name,
            "email": self.email,
            "birthdate": self.birthdate.strftime('%Y-%m-%d') if self.birthdate else None,
            "gender": self.gender,
            "goal": self.goal,
            "weight": self.weight,
            "height": self.height,
        }


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
            "benefits": self.benefits.split(";")  # رجع المميزات على شكل قائمة
        }

class UserPlan(db.Model):
    __tablename__ = "user_plans"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    plan_id = db.Column(db.Integer, db.ForeignKey('plans.id'), nullable=False)
    start_date = db.Column(db.Date, default=datetime.utcnow)
    
    user = db.relationship('User', backref='plans')
    plan = db.relationship('Plan')