import jwt
from datetime import datetime, date
from flask import Blueprint, request, jsonify, current_app
from models import User, Plan, UserPlan
from extensions import db

user_bp = Blueprint("user", __name__, url_prefix="/user")


def get_current_user():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None, jsonify({"message": "Missing or invalid token"}), 401

    token = auth_header.split(" ")[1]

    try:
        payload = jwt.decode(
            token,
            current_app.config["SECRET_KEY"],
            algorithms=["HS256"]
        )
        user = User.query.get(payload["user_id"])
        if not user:
            return None, jsonify({"message": "User not found"}), 404
        return user, None, None
    except jwt.ExpiredSignatureError:
        return None, jsonify({"message": "Token expired"}), 401
    except jwt.InvalidTokenError:
        return None, jsonify({"message": "Invalid token"}), 401


# ---------------- User Profile ----------------
@user_bp.route("/profile", methods=["GET"])
def get_profile():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    return jsonify({"user": user.to_dict()}), 200


@user_bp.route("/profile", methods=["PUT"])
def update_profile():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    data = request.get_json() or {}

    if "full_name" in data:
        user.full_name = data["full_name"]
    if "birthdate" in data:
        try:
            user.birthdate = datetime.strptime(data["birthdate"], "%Y-%m-%d").date()
        except:
            return jsonify({"message": "Invalid birthdate format. Use YYYY-MM-DD"}), 400
    if "gender" in data:
        user.gender = data["gender"]
    if "goal" in data:
        user.goal = data["goal"]
    if "weight" in data:
        user.weight = float(data["weight"]) if data["weight"] is not None else None
    if "height" in data:
        user.height = float(data["height"]) if data["height"] is not None else None

    db.session.commit()

    return jsonify({
        "message": "Profile updated successfully",
        "user": user.to_dict()
    }), 200


# ---------------- Plan Application ----------------
@user_bp.route("/plan/apply", methods=["POST"])
def apply_plan():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    data = request.get_json() or {}
    plan_id = data.get("plan_id")
    if not plan_id:
        return jsonify({"message": "plan_id is required"}), 400

    plan = Plan.query.get(plan_id)
    if not plan:
        return jsonify({"message": "Plan not found"}), 404

    # تخزين اختيار المستخدم
    user_plan = UserPlan(user_id=user.id, plan_id=plan.id)
    db.session.add(user_plan)
    db.session.commit()

    return jsonify({
        "message": "Plan applied successfully",
        "plan": plan.to_dict()  # رجع التفاصيل مباشرة للواجهة
    }), 200


# ---------------- Plan Calories ----------------
@user_bp.route("/plan/calories", methods=["GET"])
def calculate_calories():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    if not all([user.weight, user.height, user.birthdate, user.gender, user.goal]):
        return jsonify({"message": "User profile incomplete"}), 400

    age = (date.today() - user.birthdate).days // 365

    # Mifflin-St Jeor BMR calculation
    if user.gender.lower() == "male":
        bmr = 10 * user.weight + 6.25 * user.height - 5 * age + 5
    else:
        bmr = 10 * user.weight + 6.25 * user.height - 5 * age - 161

    # Adjust based on goal
    if user.goal.lower() == "lose weight":
        calories = bmr - 500
    elif user.goal.lower() == "gain weight":
        calories = bmr + 500
    else:
        calories = bmr  # maintain

    # Macronutrients
    protein = int(calories * 0.25 / 4)
    fats = int(calories * 0.25 / 9)
    carbs = int(calories * 0.5 / 4)

    return jsonify({
        "calories": round(calories),
        "protein": protein,
        "fats": fats,
        "carbs": carbs,
        "health_score": 7,  # placeholder
        "weight_loss_target": "Lose 10 kg by October 31"
    }), 200