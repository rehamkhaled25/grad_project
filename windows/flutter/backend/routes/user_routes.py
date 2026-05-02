import os
import uuid
import jwt
import requests

from datetime import datetime, date
from flask import Blueprint, request, jsonify, current_app
from sqlalchemy import text
from werkzeug.utils import secure_filename

from models import Plan, UserPlan, UserFoodLog
from extensions import db

user_bp = Blueprint("user", __name__)

# ---------------- Helper: Current User ----------------
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

        user = db.session.execute(
            text("SELECT id, full_name, email FROM users WHERE id = :id"),
            {"id": payload["user_id"]}
        ).mappings().first()

        if not user:
            return None, jsonify({"message": "User not found"}), 404

        return user, None, None

    except jwt.ExpiredSignatureError:
        return None, jsonify({"message": "Token expired"}), 401
    except jwt.InvalidTokenError:
        return None, jsonify({"message": "Invalid token"}), 401


# ---------------- Helper: Save Image ----------------
def save_image_temporarily(image):
    upload_folder = os.path.join(current_app.root_path, "uploads")
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)

    filename = secure_filename(image.filename)
    scan_id = str(uuid.uuid4())
    new_filename = f"{scan_id}_{filename}"
    file_path = os.path.join(upload_folder, new_filename)
    image.save(file_path)
    return scan_id


# ---------------- User Profile ----------------
@user_bp.route("/profile", methods=["GET"])
def get_profile():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    user_data = db.session.execute(
        text("""
            SELECT id, full_name, email, gender, goal, weight, height, birthdate
            FROM users
            WHERE id = :id
            LIMIT 1
        """),
        {"id": user["id"]}
    ).mappings().first()

    return jsonify({"user": dict(user_data)}), 200


@user_bp.route("/profile", methods=["PUT"])
def update_profile():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    data = request.get_json() or {}
    allowed_fields = {}

    if "full_name" in data:
        allowed_fields["full_name"] = data["full_name"]
    if "birthdate" in data:
        try:
            datetime.strptime(data["birthdate"], "%Y-%m-%d")
            allowed_fields["birthdate"] = data["birthdate"]
        except:
            return jsonify({"message": "Invalid birthdate format. Use YYYY-MM-DD"}), 400
    if "gender" in data:
        allowed_fields["gender"] = data["gender"]
    if "goal" in data:
        allowed_fields["goal"] = data["goal"]
    if "weight" in data:
        allowed_fields["weight"] = float(data["weight"]) if data["weight"] is not None else None
    if "height" in data:
        allowed_fields["height"] = float(data["height"]) if data["height"] is not None else None

    if allowed_fields:
        set_clause = ", ".join([f"{key} = :{key}" for key in allowed_fields.keys()])
        allowed_fields["id"] = user["id"]
        db.session.execute(
            text(f"UPDATE users SET {set_clause} WHERE id = :id"),
            allowed_fields
        )
        db.session.commit()

    return jsonify({"message": "Profile updated successfully"}), 200


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

    user_plan = UserPlan(user_id=user["id"], plan_id=plan.id)
    db.session.add(user_plan)
    db.session.commit()

    return jsonify({
        "message": "Plan applied successfully",
        "plan": plan.to_dict()
    }), 200


# ---------------- Plan Calories ----------------
@user_bp.route("/plan/calories", methods=["GET"])
def calculate_calories():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    user_data = db.session.execute(
        text("""
            SELECT weight, height, birthdate, gender, goal
            FROM users
            WHERE id = :id
            LIMIT 1
        """),
        {"id": user["id"]}
    ).mappings().first()

    if not all([user_data["weight"], user_data["height"], user_data["birthdate"],
                user_data["gender"], user_data["goal"]]):
        return jsonify({"message": "User profile incomplete"}), 400

    birthdate_value = str(user_data["birthdate"])
    if birthdate_value.isdigit() and len(birthdate_value) == 4:
        birthdate_value = f"{birthdate_value}-01-01"
    birthdate_date = datetime.strptime(birthdate_value, "%Y-%m-%d").date()

    age = (date.today() - birthdate_date).days // 365
    weight = float(user_data["weight"])
    height = float(user_data["height"])
    gender = user_data["gender"].lower()
    goal = user_data["goal"].lower()

    if gender == "male":
        bmr = 10 * weight + 6.25 * height - 5 * age + 5
    else:
        bmr = 10 * weight + 6.25 * height - 5 * age - 161

    if goal == "lose weight":
        calories = bmr - 500
    elif goal == "gain weight":
        calories = bmr + 500
    else:
        calories = bmr

    protein = int(calories * 0.25 / 4)
    fats = int(calories * 0.25 / 9)
    carbs = int(calories * 0.5 / 4)

    return jsonify({
        "calories": round(calories),
        "protein": protein,
        "fats": fats,
        "carbs": carbs,
        "health_score": 7,
        "weight_loss_target": "Lose 10 kg by October 31"
    }), 200


# ---------------- Food Logging ----------------
@user_bp.route("/food/scan", methods=["POST"])
def scan_food():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    image = request.files.get("image")
    if not image:
        return jsonify({"message": "Image is required"}), 400

    scan_id = save_image_temporarily(image)
    return jsonify({"message": "Image uploaded successfully", "scan_id": scan_id}), 200


@user_bp.route("/food/analyze/<scan_id>", methods=["POST"])
def analyze_food(scan_id):
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    # بدل placeholder، نعمل request للـ Colab API
    colab_api_url = "https://utmost-barometer-aim.ngrok-free.dev"  # حط Public URL من ngrok
    payload = {"scan_id": scan_id}
    response = requests.post(colab_api_url, json=payload)
    ai_result = response.json()

    return jsonify(ai_result), 200


@user_bp.route("/food/log", methods=["POST"])
def log_food():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    data = request.get_json() or {}
    required_fields = ["food_name", "calories", "protein", "carbs", "fats", "serving_size"]
    for field in required_fields:
        if field not in data:
            return jsonify({"message": f"{field} is required"}), 400

    log = UserFoodLog(
        user_id=user["id"],
        food_name=data["food_name"],
        calories=data["calories"],
        protein=data["protein"],
        carbs=data["carbs"],
        fats=data["fats"],
        serving_size=data["serving_size"],
        ai_scan=data.get("ai_scan", False),
        log_time=datetime.utcnow()
    )

    db.session.add(log)
    db.session.commit()
    return jsonify({"message": "Food logged successfully", "food_log": log.to_dict()}), 200


@user_bp.route("/food/search", methods=["GET"])
def search_food():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    query = request.args.get("query", "")
    tab = request.args.get("tab", "all")
    results = [
        {"food_name": "Apple", "calories": 95},
        {"food_name": "Banana", "calories": 105},
        {"food_name": "Rice", "calories": 206}
    ]
    if query:
        results = [f for f in results if query.lower() in f["food_name"].lower()]

    return jsonify({"results": results}), 200


@user_bp.route("/food/history", methods=["GET"])
def food_history():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    logs = UserFoodLog.query.filter_by(user_id=user["id"]).order_by(UserFoodLog.log_time.desc()).all()
    return jsonify([log.to_dict() for log in logs]), 200
