import os
import uuid
import jwt
import requests
import json

from datetime import datetime, date
from flask import Blueprint, request, jsonify, current_app
from sqlalchemy import text
from werkzeug.utils import secure_filename

from models import Plan, UserPlan, UserFoodLog, FoodScan
from extensions import db
from services.gemini_service import analyze_meal

user_bp = Blueprint("user", __name__)


# ---------------- Helper: Current User ----------------
def get_current_user():
    auth_header = request.headers.get("Authorization", "")

    if not auth_header.startswith("Bearer "):
        return None, jsonify({"message": "Missing or invalid token"}), 401

    token = auth_header.split(" ")[1]

    try:
        payload = jwt.decode(
            token, current_app.config["SECRET_KEY"], algorithms=["HS256"]
        )

        user = (
            db.session.execute(
                text("SELECT id, full_name, email FROM users WHERE id = :id"),
                {"id": payload["user_id"]},
            )
            .mappings()
            .first()
        )

        if not user:
            return None, jsonify({"message": "User not found"}), 404

        return user, None, None

    except jwt.ExpiredSignatureError:
        return None, jsonify({"message": "Token expired"}), 401

    except jwt.InvalidTokenError:
        return None, jsonify({"message": "Invalid token"}), 401


# ---------------- Helper: Allergies ----------------
def allergies_to_text(allergies):
    if allergies is None:
        return None

    if isinstance(allergies, list):
        return ",".join([str(item).strip() for item in allergies if str(item).strip()])

    if isinstance(allergies, str):
        return allergies.strip()

    return None


def allergies_to_list(allergies_text):
    if not allergies_text:
        return []

    return [item.strip() for item in str(allergies_text).split(",") if item.strip()]


# ---------------- Helper: Save Image ----------------
def save_food_scan(user_id, image):
    upload_folder = os.path.join(
        current_app.root_path, current_app.config.get("UPLOAD_FOLDER", "uploads")
    )

    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)

    original_filename = secure_filename(image.filename or "food_image.jpg")
    scan_id = str(uuid.uuid4())
    new_filename = f"{scan_id}_{original_filename}"
    file_path = os.path.join(upload_folder, new_filename)

    image.save(file_path)

    scan = FoodScan(
        scan_id=scan_id,
        user_id=user_id,
        image_path=file_path,
    )

    db.session.add(scan)
    db.session.commit()

    return scan


# ---------------- User Profile ----------------
@user_bp.route("/profile", methods=["GET"])
def get_profile():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    user_data = (
        db.session.execute(
            text("""
            SELECT
                id,
                full_name,
                email,
                gender,
                goal,
                weight,
                height,
                goal_weight,
                allergies,
                birthdate
            FROM users
            WHERE id = :id
            LIMIT 1
        """),
            {"id": user["id"]},
        )
        .mappings()
        .first()
    )

    if not user_data:
        return jsonify({"message": "User not found"}), 404

    result = dict(user_data)
    result["allergies"] = allergies_to_list(result.get("allergies"))

    return jsonify({"user": result}), 200


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
        if data["birthdate"] is None or data["birthdate"] == "":
            allowed_fields["birthdate"] = None
        else:
            try:
                datetime.strptime(data["birthdate"], "%Y-%m-%d")
                allowed_fields["birthdate"] = data["birthdate"]
            except Exception:
                return (
                    jsonify({"message": "Invalid birthdate format. Use YYYY-MM-DD"}),
                    400,
                )

    if "gender" in data:
        allowed_fields["gender"] = data["gender"]

    if "goal" in data:
        allowed_fields["goal"] = data["goal"]

    if "weight" in data:
        try:
            allowed_fields["weight"] = (
                float(data["weight"]) if data["weight"] is not None else None
            )
        except Exception:
            return jsonify({"message": "weight must be a number"}), 400

    if "height" in data:
        try:
            allowed_fields["height"] = (
                float(data["height"]) if data["height"] is not None else None
            )
        except Exception:
            return jsonify({"message": "height must be a number"}), 400

    if "goal_weight" in data:
        try:
            allowed_fields["goal_weight"] = (
                float(data["goal_weight"]) if data["goal_weight"] is not None else None
            )
        except Exception:
            return jsonify({"message": "goal_weight must be a number"}), 400

    if "allergies" in data:
        allergies_text = allergies_to_text(data["allergies"])

        if allergies_text is None and data["allergies"] is not None:
            return jsonify({"message": "allergies must be a list or string"}), 400

        allowed_fields["allergies"] = allergies_text

    if not allowed_fields:
        return jsonify({"message": "No valid fields provided"}), 400

    set_clause = ", ".join([f"{key} = :{key}" for key in allowed_fields.keys()])
    allowed_fields["id"] = user["id"]

    db.session.execute(
        text(f"UPDATE users SET {set_clause} WHERE id = :id"), allowed_fields
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

    return (
        jsonify({"message": "Plan applied successfully", "plan": plan.to_dict()}),
        200,
    )


# ---------------- Plan Calories ----------------
@user_bp.route("/plan/calories", methods=["GET"])
def calculate_calories():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    user_data = (
        db.session.execute(
            text("""
            SELECT weight, height, birthdate, gender, goal
            FROM users
            WHERE id = :id
            LIMIT 1
        """),
            {"id": user["id"]},
        )
        .mappings()
        .first()
    )

    if not all(
        [
            user_data["weight"],
            user_data["height"],
            user_data["birthdate"],
            user_data["gender"],
            user_data["goal"],
        ]
    ):
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

    if goal == "lose weight" or goal == "lose_weight":
        calories = bmr - 500
    elif goal == "gain weight" or goal == "gain_weight":
        calories = bmr + 500
    else:
        calories = bmr

    protein = int(calories * 0.25 / 4)
    fats = int(calories * 0.25 / 9)
    carbs = int(calories * 0.5 / 4)

    return (
        jsonify(
            {
                "calories": round(calories),
                "protein": protein,
                "fats": fats,
                "carbs": carbs,
                "health_score": 7,
                "weight_loss_target": "Lose 10 kg by October 31",
            }
        ),
        200,
    )


# ---------------- Food Logging ----------------
@user_bp.route("/food/scan", methods=["POST"])
def scan_food():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    image = request.files.get("image")

    if not image:
        return jsonify({"message": "Image is required"}), 400

    scan = save_food_scan(user["id"], image)

    return (
        jsonify(
            {
                "message": "Image uploaded successfully",
                "scan": scan.to_dict(),
            }
        ),
        201,
    )


@user_bp.route("/food/analyze/<scan_id>", methods=["POST"])
def analyze_food(scan_id):
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    scan = FoodScan.query.filter_by(scan_id=scan_id, user_id=user["id"]).first()

    if not scan:
        return jsonify({"message": "Scan not found"}), 404

    data = request.get_json(silent=True) or {}
    context = data.get("context", "")

    try:
        report = analyze_meal(scan.image_path, context)
    except Exception as e:
        return jsonify({"message": "AI analysis failed", "error": str(e)}), 500

    health_score = report.get("health_score")

    try:
        health_score = float(health_score)
        if health_score > 10:
            health_score = round(health_score / 10)
        health_score = max(0, min(10, int(health_score)))
    except Exception:
        health_score = None

    health_score = report.get("health_score")

    try:
        health_score = float(health_score)

        # Gemini sometimes returns score as percentage like 50 or 68.
        # We convert it to 0-10.
        if health_score > 10:
            health_score = round(health_score / 10)

        health_score = max(0, min(10, int(health_score)))
    except Exception:
        health_score = None

    # Force the report itself to store the corrected score
    report["health_score"] = health_score

    scan.context = context
    scan.meal_name = report.get("meal_name")
    scan.calories = report.get("total_calories")
    scan.protein = report.get("total_protein")
    scan.carbs = report.get("total_carbs")
    scan.fat = report.get("total_fat")
    scan.health_score = health_score
    scan.full_report = json.dumps(report)
    scan.analyzed_at = datetime.utcnow()

    db.session.commit()

    ui = {
        "scan_id": scan.scan_id,
        "meal_name": scan.meal_name,
        "image_path": scan.image_path,
        "calories": scan.calories,
        "protein": scan.protein,
        "carbs": scan.carbs,
        "fat": scan.fat,
        "health_score": scan.health_score,
    }

    return (
        jsonify(
            {
                "message": "Food analyzed successfully",
                "ui": ui,
                "report": report,
            }
        ),
        200,
    )


@user_bp.route("/food/scans/<scan_id>", methods=["GET"])
def get_food_scan_details(scan_id):
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    scan = FoodScan.query.filter_by(scan_id=scan_id, user_id=user["id"]).first()

    if not scan:
        return jsonify({"message": "Scan not found"}), 404

    full_report = json.loads(scan.full_report) if scan.full_report else None

    return (
        jsonify(
            {
                "scan": scan.to_dict(),
                "report": full_report,
            }
        ),
        200,
    )


@user_bp.route("/food/log", methods=["POST"])
def log_food():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    data = request.get_json() or {}

    required_fields = [
        "food_name",
        "calories",
        "protein",
        "carbs",
        "fats",
        "serving_size",
    ]

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
        log_time=datetime.utcnow(),
    )

    db.session.add(log)
    db.session.commit()

    return (
        jsonify({"message": "Food logged successfully", "food_log": log.to_dict()}),
        200,
    )


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
        {"food_name": "Rice", "calories": 206},
    ]

    if query:
        results = [
            food for food in results if query.lower() in food["food_name"].lower()
        ]

    return jsonify({"results": results}), 200


@user_bp.route("/food/history", methods=["GET"])
def food_history():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    logs = (
        UserFoodLog.query.filter_by(user_id=user["id"])
        .order_by(UserFoodLog.log_time.desc())
        .all()
    )

    return jsonify([log.to_dict() for log in logs]), 200
