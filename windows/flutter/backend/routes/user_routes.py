import os
import uuid
import jwt
import requests
import json

from datetime import datetime, date
from flask import Blueprint, request, jsonify, current_app, send_from_directory
from sqlalchemy import text
from werkzeug.utils import secure_filename

from models import Plan, UserPlan, UserFoodLog, FoodScan, UserWeightLog
from extensions import db
from services.gemini_service import analyze_meal, analyze_food_name

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


# ---------------- General Helpers ----------------
def to_float(value, default=0):
    try:
        if value is None or value == "":
            return default
        return float(value)
    except Exception:
        return default


def normalize_meal_type(meal_type):
    allowed = ["breakfast", "lunch", "dinner", "snack"]

    if not meal_type:
        return "snack"

    meal_type = str(meal_type).lower().strip()

    if meal_type not in allowed:
        return "snack"

    return meal_type


def normalize_health_score(value):
    try:
        score = float(value)

        if score > 10:
            score = round(score / 10)

        return max(0, min(10, int(score)))
    except Exception:
        return None


def safe_json_loads(value):
    if not value:
        return None

    try:
        return json.loads(value)
    except Exception:
        return None


def parse_limit(default=20, maximum=50):
    limit = request.args.get("limit", default)

    try:
        limit = int(limit)
    except Exception:
        limit = default

    return max(1, min(limit, maximum))


# ---------------- Helper: Profile Image ----------------
def save_profile_image(user_id, image):
    upload_folder = os.path.join(
        current_app.root_path,
        current_app.config.get("UPLOAD_FOLDER", "uploads"),
        "profile_images",
    )

    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)

    original_filename = secure_filename(image.filename or "profile_image.jpg")
    extension = os.path.splitext(original_filename)[1]
    filename = f"user_{user_id}_{uuid.uuid4()}{extension}"
    file_path = os.path.join(upload_folder, filename)

    image.save(file_path)

    return filename


def build_profile_image_url(filename):
    if not filename:
        return None

    return request.host_url.rstrip("/") + f"/user/profile/image/{filename}"


def build_scan_image_url(image_path):
    """Convert a raw filesystem image_path to a publicly accessible URL."""
    if not image_path:
        return None

    filename = os.path.basename(image_path)
    return request.host_url.rstrip("/") + f"/user/food/scans/image/{filename}"

# ---------------- USDA FoodData Central Helpers ----------------
def get_fdc_api_key():
    return current_app.config.get("FDC_API_KEY") or os.getenv("FDC_API_KEY") or "DEMO_KEY"


def fdc_nutrient_value(food_nutrients, possible_names, default=0):
    if not food_nutrients:
        return default

    possible_names = [name.lower() for name in possible_names]

    for nutrient in food_nutrients:
        name = (
            nutrient.get("nutrientName")
            or nutrient.get("name")
            or nutrient.get("nutrient", {}).get("name")
            or ""
        ).lower()

        value = (
            nutrient.get("value")
            or nutrient.get("amount")
            or nutrient.get("nutrientNumber")
        )

        for possible_name in possible_names:
            if possible_name in name:
                return to_float(value, default)

    return default


def normalize_usda_food(food):
    food_nutrients = food.get("foodNutrients", [])

    calories = fdc_nutrient_value(
        food_nutrients,
        ["Energy"],
        0,
    )

    protein = fdc_nutrient_value(
        food_nutrients,
        ["Protein"],
        0,
    )

    carbs = fdc_nutrient_value(
        food_nutrients,
        ["Carbohydrate, by difference", "Carbohydrate"],
        0,
    )

    fats = fdc_nutrient_value(
        food_nutrients,
        ["Total lipid", "fat"],
        0,
    )

    serving_size = food.get("servingSize")
    serving_unit = food.get("servingSizeUnit")

    if serving_size and serving_unit:
        serving_text = f"{serving_size} {serving_unit}"
    else:
        serving_text = None

    return {
        "source": "usda_fdc",
        "fdc_id": food.get("fdcId"),
        "barcode": food.get("gtinUpc"),
        "food_name": food.get("description") or "Unknown food",
        "brand": food.get("brandOwner") or food.get("brandName"),
        "category": food.get("dataType"),
        "serving_size": serving_text,
        "image_url": None,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fats": fats,
    }


def search_usda_food_data(query, limit):
    api_key = get_fdc_api_key()

    if not api_key:
        return {
            "external_error": True,
            "status_code": None,
            "message": "FDC_API_KEY is missing",
            "results": [],
        }

    response = requests.get(
        "https://api.nal.usda.gov/fdc/v1/foods/search",
        params={
            "api_key": api_key,
            "query": query,
            "pageSize": limit,
            "dataType": ["Branded", "Foundation", "SR Legacy"],
        },
        timeout=15,
        verify=False,
    )

    if response.status_code != 200:
        return {
            "external_error": True,
            "status_code": response.status_code,
            "message": "USDA FoodData Central search failed",
            "results": [],
        }

    data = response.json()
    foods = data.get("foods", [])

    return {
        "external_error": False,
        "status_code": 200,
        "message": "USDA FoodData Central search successful",
        "results": [normalize_usda_food(food) for food in foods],
    }


def get_usda_food_details(fdc_id):
    api_key = get_fdc_api_key()

    if not api_key:
        return None

    response = requests.get(
        f"https://api.nal.usda.gov/fdc/v1/food/{fdc_id}",
        params={"api_key": api_key},
        timeout=15,
        verify=False,
    )

    if response.status_code != 200:
        return None

    return response.json()


def build_usda_serving_details(food):
    normalized = normalize_usda_food(food)
    food_nutrients = food.get("foodNutrients", [])

    fiber = fdc_nutrient_value(
        food_nutrients,
        ["Fiber", "Fiber, total dietary"],
        0,
    )

    sugar = fdc_nutrient_value(
        food_nutrients,
        ["Sugars", "Sugars, total"],
        0,
    )

    sodium = fdc_nutrient_value(
        food_nutrients,
        ["Sodium", "Sodium, Na"],
        0,
    )

    serving_size = food.get("servingSize")
    serving_unit = food.get("servingSizeUnit")

    servings = []

    if serving_size and serving_unit:
        servings.append(
            {
                "serving_name": f"{serving_size} {serving_unit}",
                "grams": (
                    serving_size
                    if str(serving_unit).lower() in ["g", "gram", "grams"]
                    else None
                ),
                "calories": normalized["calories"],
                "protein": normalized["protein"],
                "carbs": normalized["carbs"],
                "fats": normalized["fats"],
            }
        )

    servings.append(
        {
            "serving_name": "100g",
            "grams": 100,
            "calories": normalized["calories"],
            "protein": normalized["protein"],
            "carbs": normalized["carbs"],
            "fats": normalized["fats"],
        }
    )

    return {
        "food": normalized,
        "servings": servings,
        "nutrition_facts": {
            "fiber": fiber,
            "sugar": sugar,
            "sodium": sodium,
        },
    }


# ---------------- Open Food Facts Helpers ----------------
def open_food_facts_headers():
    return {"User-Agent": "EcoDrive-My-Work/1.0 - Graduation Project Backend"}


def nutriment_value(nutriments, keys, default=0):
    for key in keys:
        value = nutriments.get(key)

        if value is not None and value != "":
            return to_float(value, default)

    return default


def normalize_open_food_product(product):
    nutriments = product.get("nutriments", {})

    calories = nutriment_value(
        nutriments,
        ["energy-kcal_serving", "energy-kcal_100g"],
        0,
    )

    protein = nutriment_value(
        nutriments,
        ["proteins_serving", "proteins_100g"],
        0,
    )

    carbs = nutriment_value(
        nutriments,
        ["carbohydrates_serving", "carbohydrates_100g"],
        0,
    )

    fats = nutriment_value(
        nutriments,
        ["fat_serving", "fat_100g"],
        0,
    )

    return {
        "source": "open_food_facts",
        "barcode": product.get("code"),
        "food_name": product.get("product_name") or "Unknown product",
        "brand": product.get("brands"),
        "category": product.get("categories"),
        "serving_size": product.get("serving_size"),
        "image_url": product.get("image_front_url"),
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fats": fats,
    }


def search_open_food_facts(query, limit):
    fields = ",".join(
        [
            "code",
            "product_name",
            "brands",
            "categories",
            "serving_size",
            "image_front_url",
            "nutriments",
        ]
    )

    response = requests.get(
        "https://world.openfoodfacts.org/cgi/search.pl",
        params={
            "search_terms": query,
            "search_simple": "1",
            "action": "process",
            "json": "1",
            "page_size": limit,
            "fields": fields,
        },
        headers=open_food_facts_headers(),
        timeout=15,
        verify=False,
    )

    if response.status_code != 200:
        raise RuntimeError(f"Open Food Facts failed with status {response.status_code}")

    data = response.json()
    products = data.get("products", [])

    return [normalize_open_food_product(product) for product in products]


def get_open_food_facts_product(barcode):
    fields = ",".join(
        [
            "code",
            "product_name",
            "brands",
            "categories",
            "serving_size",
            "image_front_url",
            "nutriments",
        ]
    )

    response = requests.get(
        f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json",
        params={"fields": fields},
        headers=open_food_facts_headers(),
        timeout=15,
        verify=False,
    )

    if response.status_code != 200:
        return None

    data = response.json()
    product = data.get("product")

    if not product:
        return None

    return product


def build_open_food_serving_details(product):
    normalized = normalize_open_food_product(product)
    nutriments = product.get("nutriments", {})

    calories_100g = nutriment_value(nutriments, ["energy-kcal_100g"], 0)
    protein_100g = nutriment_value(nutriments, ["proteins_100g"], 0)
    carbs_100g = nutriment_value(nutriments, ["carbohydrates_100g"], 0)
    fats_100g = nutriment_value(nutriments, ["fat_100g"], 0)

    calories_serving = nutriment_value(
        nutriments,
        ["energy-kcal_serving"],
        normalized["calories"],
    )

    protein_serving = nutriment_value(
        nutriments,
        ["proteins_serving"],
        normalized["protein"],
    )

    carbs_serving = nutriment_value(
        nutriments,
        ["carbohydrates_serving"],
        normalized["carbs"],
    )

    fats_serving = nutriment_value(
        nutriments,
        ["fat_serving"],
        normalized["fats"],
    )

    fiber = nutriment_value(
        nutriments,
        ["fiber_serving", "fiber_100g"],
        0,
    )

    sugar = nutriment_value(
        nutriments,
        ["sugars_serving", "sugars_100g"],
        0,
    )

    sodium = nutriment_value(
        nutriments,
        ["sodium_serving", "sodium_100g"],
        0,
    )

    servings = []

    if normalized.get("serving_size"):
        servings.append(
            {
                "serving_name": normalized["serving_size"],
                "grams": None,
                "calories": calories_serving,
                "protein": protein_serving,
                "carbs": carbs_serving,
                "fats": fats_serving,
            }
        )

    servings.append(
        {
            "serving_name": "100g",
            "grams": 100,
            "calories": calories_100g,
            "protein": protein_100g,
            "carbs": carbs_100g,
            "fats": fats_100g,
        }
    )

    return {
        "food": normalized,
        "servings": servings,
        "nutrition_facts": {
            "fiber": fiber,
            "sugar": sugar,
            "sodium": sodium,
        },
    }


# ---------------- Helper: Save Image ----------------
def save_food_scan(user_id, image):
    upload_folder = os.path.join(
        current_app.root_path,
        current_app.config.get("UPLOAD_FOLDER", "uploads"),
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
                profile_image,
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
    result["profile_image_url"] = build_profile_image_url(result.get("profile_image"))
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
        text(f"UPDATE users SET {set_clause} WHERE id = :id"),
        allowed_fields,
    )

    db.session.commit()

    return jsonify({"message": "Profile updated successfully"}), 200


@user_bp.route("/profile/image", methods=["POST"])
def upload_profile_image():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    image = request.files.get("image")

    if not image:
        return jsonify({"message": "Image is required"}), 400

    filename = save_profile_image(user["id"], image)

    db.session.execute(
        text("""
            UPDATE users
            SET profile_image = :profile_image
            WHERE id = :id
        """),
        {
            "profile_image": filename,
            "id": user["id"],
        },
    )

    db.session.commit()

    return (
        jsonify(
            {
                "message": "Profile image uploaded successfully",
                "profile_image": filename,
                "profile_image_url": build_profile_image_url(filename),
            }
        ),
        200,
    )


@user_bp.route("/profile/image/<filename>", methods=["GET"])
def get_profile_image(filename):
    upload_folder = os.path.join(
        current_app.root_path,
        current_app.config.get("UPLOAD_FOLDER", "uploads"),
        "profile_images",
    )

    return send_from_directory(upload_folder, filename)


@user_bp.route("/food/scans/image/<filename>", methods=["GET"])
def get_food_scan_image(filename):
    upload_folder = os.path.join(
        current_app.root_path,
        current_app.config.get("UPLOAD_FOLDER", "uploads"),
    )

    return send_from_directory(upload_folder, filename)


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
            SELECT weight, height, birthdate, gender, goal, goal_weight
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

    required_fields = {
        "weight": user_data["weight"],
        "height": user_data["height"],
        "birthdate": user_data["birthdate"],
        "gender": user_data["gender"],
        "goal": user_data["goal"],
        "goal_weight": user_data["goal_weight"],
    }

    missing_fields = [
        field
        for field, value in required_fields.items()
        if value is None or value == ""
    ]

    if missing_fields:
        return (
            jsonify(
                {"message": "User profile incomplete", "missing_fields": missing_fields}
            ),
            400,
        )

    birthdate_value = str(user_data["birthdate"])

    if birthdate_value.isdigit() and len(birthdate_value) == 4:
        birthdate_value = f"{birthdate_value}-01-01"

    birthdate_date = datetime.strptime(birthdate_value, "%Y-%m-%d").date()

    age = (date.today() - birthdate_date).days // 365
    weight = float(user_data["weight"])
    height = float(user_data["height"])
    goal_weight = float(user_data["goal_weight"])
    gender = user_data["gender"].lower()
    goal = user_data["goal"].lower()

    if gender == "male":
        bmr = 10 * weight + 6.25 * height - 5 * age + 5
    else:
        bmr = 10 * weight + 6.25 * height - 5 * age - 161

    # مؤقتًا activity factor ثابت متوسط
    maintenance_calories = bmr * 1.35

    weight_difference = goal_weight - weight

    if weight_difference < 0:
        goal_direction = "lose_weight"
        calories = maintenance_calories - 500
        weekly_change_kg = 0.5
    elif weight_difference > 0:
        goal_direction = "gain_weight"
        calories = maintenance_calories + 400
        weekly_change_kg = 0.35
    else:
        goal_direction = "maintain_weight"
        calories = maintenance_calories
        weekly_change_kg = 0

    # حماية من أرقام قليلة جدًا
    if gender == "male":
        calories = max(calories, 1500)
    else:
        calories = max(calories, 1200)

    if weekly_change_kg > 0:
        estimated_weeks = round(abs(weight_difference) / weekly_change_kg)
    else:
        estimated_weeks = 0

    protein = int(weight * 1.8)
    fats = int(calories * 0.25 / 9)
    carbs = int((calories - (protein * 4) - (fats * 9)) / 4)

    carbs = max(carbs, 0)

    if goal_direction == "lose_weight":
        target_summary = (
            f"Lose {abs(round(weight_difference, 1))} kg to reach {goal_weight} kg"
        )
    elif goal_direction == "gain_weight":
        target_summary = (
            f"Gain {abs(round(weight_difference, 1))} kg to reach {goal_weight} kg"
        )
    else:
        target_summary = f"Maintain your current weight around {weight} kg"

    return (
        jsonify(
            {
                "calories": round(calories),
                "maintenance_calories": round(maintenance_calories),
                "protein": protein,
                "fats": fats,
                "carbs": carbs,
                "health_score": 7,
                "current_weight": weight,
                "goal_weight": goal_weight,
                "weight_difference": round(weight_difference, 1),
                "goal_direction": goal_direction,
                "estimated_weeks": estimated_weeks,
                "target_summary": target_summary,
            }
        ),
        200,
    )


# ---------------- Camera + Analysis ----------------
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

    from models import User
    db_user = User.query.get(user["id"])
    if db_user and db_user.allergies:
        allergies_str = db_user.allergies
        allergy_instruction = (
            f"\n\n[ALLERGY WARNING CRITICAL INSTRUCTION]: The user has the following allergies/dietary restrictions: {allergies_str}. "
            "Examine the food in the image carefully for these ingredients. "
            "If any of these allergens are detected or likely present in the food, you MUST write a clear warning in the 'metabolic_warning' field of the response. "
            "Do NOT list the user's allergies themselves in the warning; only mention the specific warning describing which allergen is present (e.g., 'Warning: This meal contains dairy'). "
            "If no matching allergens are present, keep 'metabolic_warning' empty or list general metabolic comments."
        )
        context = f"{context}{allergy_instruction}"

    try:
        report = analyze_meal(scan.image_path, context)
    except Exception as e:
        return jsonify({"message": "AI analysis failed", "error": str(e)}), 500

    health_score = normalize_health_score(report.get("health_score"))
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
        "source": "saved_scans",
        "scan_id": scan.scan_id,
        "food_name": scan.meal_name,
        "meal_name": scan.meal_name,
        "image_path": scan.image_path,
        "calories": scan.calories,
        "protein": scan.protein,
        "carbs": scan.carbs,
        "fats": scan.fat,
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

    full_report = safe_json_loads(scan.full_report)

    return (
        jsonify(
            {
                "scan": scan.to_dict(),
                "report": full_report,
            }
        ),
        200,
    )


@user_bp.route("/food/scans/recent", methods=["GET"])
def get_recent_food_scans():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    limit = parse_limit(default=20, maximum=50)

    scans = (
        FoodScan.query.filter_by(user_id=user["id"])
        .order_by(FoodScan.created_at.desc())
        .limit(limit)
        .all()
    )

    return (
        jsonify(
            {
                "count": len(scans),
                "scans": [scan.to_dict() for scan in scans],
            }
        ),
        200,
    )


# ---------------- Log Food ----------------
@user_bp.route("/food/log", methods=["POST"])
def log_food():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    data = request.get_json() or {}

    scan_id = data.get("scan_id")
    food_name = data.get("food_name")
    serving_size_input = data.get("serving_size", "")
    context = data.get("context", "")
    image_url_input = data.get("image_url", "")

    scan = None
    report = None

    has_direct_nutrition_values = any(
        key in data for key in ["calories", "protein", "carbs", "fats", "fat"]
    )

    # Case 1: Log from AI image scan
    if scan_id:
        scan = FoodScan.query.filter_by(scan_id=scan_id, user_id=user["id"]).first()

        if not scan:
            return jsonify({"message": "Scan not found"}), 404

        if not scan.meal_name:
            return jsonify({"message": "Scan is not analyzed yet"}), 400

        food_name = scan.meal_name

        if scan.full_report:
            report = safe_json_loads(scan.full_report)

        calories = scan.calories
        protein = scan.protein
        carbs = scan.carbs
        fats = scan.fat
        ai_scan = True

    # Case 2: Add food from database/search/serving page
    elif has_direct_nutrition_values:
        if not food_name:
            return jsonify({"message": "food_name is required"}), 400

        calories = data.get("calories", 0)
        protein = data.get("protein", 0)
        carbs = data.get("carbs", 0)
        fats = data.get("fats", data.get("fat", 0))
        report = data.get("report")
        ai_scan = bool(data.get("ai_scan", False))

    # Case 3: User logs food name only, Gemini estimates values
    else:
        if not food_name:
            return jsonify({"message": "food_name is required"}), 400

        from models import User
        db_user = User.query.get(user["id"])
        if db_user and db_user.allergies:
            allergies_str = db_user.allergies
            allergy_instruction = (
                f"\n\n[ALLERGY WARNING CRITICAL INSTRUCTION]: The user has the following allergies/dietary restrictions: {allergies_str}. "
                "Examine the food entry carefully for these ingredients. "
                "If any of these allergens are detected or likely present in the food, you MUST write a clear warning in the 'metabolic_warning' field of the response. "
                "Do NOT list the user's allergies themselves in the warning; only mention the specific warning describing which allergen is present (e.g., 'Warning: This meal contains dairy'). "
                "If no matching allergens are present, keep 'metabolic_warning' empty or list general metabolic comments."
            )
            context = f"{context}{allergy_instruction}"

        try:
            report = analyze_food_name(
                food_name=food_name,
                serving_size=serving_size_input,
                context=context,
            )
        except Exception as e:
            return (
                jsonify(
                    {
                        "message": "Food name analysis failed",
                        "error": str(e),
                    }
                ),
                500,
            )

        health_score = normalize_health_score(report.get("health_score"))
        report["health_score"] = health_score

        food_name = report.get("meal_name") or food_name
        calories = report.get("total_calories", 0)
        protein = report.get("total_protein", 0)
        carbs = report.get("total_carbs", 0)
        fats = report.get("total_fat", 0)
        ai_scan = True

    if isinstance(report, dict):
        full_report = json.dumps(report)
    elif isinstance(report, str):
        full_report = report
    else:
        full_report = None

    log = UserFoodLog(
        user_id=user["id"],
        food_name=food_name,
        calories=to_float(calories),
        protein=to_float(protein),
        carbs=to_float(carbs),
        fats=to_float(fats),
        serving_size=to_float(data.get("serving_size"), 1),
        meal_type=normalize_meal_type(data.get("meal_type")),
        scan_id=scan_id,
        food_item_id=data.get("food_item_id"),
        serving_name=data.get("serving_name") or str(serving_size_input),
        image_url=image_url_input,
        full_report=full_report,
        ai_scan=ai_scan,
        log_time=datetime.utcnow(),
    )

    db.session.add(log)
    db.session.commit()

    return (
        jsonify(
            {
                "message": "Food logged successfully",
                "food_log": log.to_dict(),
                "report": report,
            }
        ),
        201,
    )


@user_bp.route("/food/history", methods=["GET"])
def food_history():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    meal_type = request.args.get("meal_type")
    date_filter = request.args.get("date")

    query = UserFoodLog.query.filter_by(user_id=user["id"])

    if meal_type:
        query = query.filter_by(meal_type=normalize_meal_type(meal_type))

    if date_filter:
        try:
            selected_date = datetime.strptime(date_filter, "%Y-%m-%d").date()
            start = datetime.combine(selected_date, datetime.min.time())
            end = datetime.combine(selected_date, datetime.max.time())
            query = query.filter(
                UserFoodLog.log_time >= start,
                UserFoodLog.log_time <= end,
            )
        except Exception:
            return jsonify({"message": "Invalid date format. Use YYYY-MM-DD"}), 400

    logs = query.order_by(UserFoodLog.log_time.desc()).all()

    grouped = {
        "breakfast": [],
        "lunch": [],
        "dinner": [],
        "snack": [],
    }

    totals = {
        "calories": 0,
        "protein": 0,
        "carbs": 0,
        "fats": 0,
    }

    logs_with_images = []
    for log in logs:
        item = log.to_dict()
        # Attach a publicly accessible image URL when the log came from a scan
        if not item.get("image_url"):
            scan_image_path = None
            if log.scan_id:
                linked_scan = FoodScan.query.filter_by(scan_id=log.scan_id).first()
                if linked_scan:
                    scan_image_path = linked_scan.image_path
            item["image_url"] = build_scan_image_url(scan_image_path)

        current_meal_type = log.meal_type or "snack"
        if current_meal_type not in grouped:
            current_meal_type = "snack"
        grouped[current_meal_type].append(item)

        totals["calories"] += log.calories or 0
        totals["protein"] += log.protein or 0
        totals["carbs"] += log.carbs or 0
        totals["fats"] += log.fats or 0

        logs_with_images.append(item)

    return (
        jsonify(
            {
                "logs": logs_with_images,
                "grouped": grouped,
                "totals": {
                    "calories": round(totals["calories"], 2),
                    "protein": round(totals["protein"], 2),
                    "carbs": round(totals["carbs"], 2),
                    "fats": round(totals["fats"], 2),
                },
            }
        ),
        200,
    )


# ---------------- Food Database Search ----------------
def search_my_meals(user_id, query, limit):
    logs_query = UserFoodLog.query.filter_by(user_id=user_id)

    if query:
        logs_query = logs_query.filter(UserFoodLog.food_name.ilike(f"%{query}%"))

    logs = logs_query.order_by(UserFoodLog.log_time.desc()).limit(limit).all()

    results = []
    for log in logs:
        image_url = None
        if log.scan_id:
            scan = FoodScan.query.filter_by(scan_id=log.scan_id).first()
            if scan and scan.image_path:
                image_url = build_scan_image_url(scan.image_path)
                
        results.append({
            "source": "my_meals",
            "log_id": log.id,
            "food_name": log.food_name,
            "calories": log.calories,
            "protein": log.protein,
            "carbs": log.carbs,
            "fats": log.fats,
            "meal_type": log.meal_type,
            "serving_size": log.serving_size,
            "serving_name": log.serving_name,
            "scan_id": log.scan_id,
            "image_url": image_url,
            "ai_scan": log.ai_scan,
            "log_time": (
                log.log_time.strftime("%Y-%m-%d %H:%M:%S") if log.log_time else None
            ),
        })
    return results


def search_my_foods(user_id, query, limit):
    logs_query = UserFoodLog.query.filter_by(user_id=user_id)

    if query:
        logs_query = logs_query.filter(UserFoodLog.food_name.ilike(f"%{query}%"))

    logs = logs_query.order_by(UserFoodLog.log_time.desc()).limit(100).all()

    unique_foods = {}

    for log in logs:
        key = log.food_name.lower().strip()

        if key not in unique_foods:
            image_url = None
            if log.scan_id:
                scan = FoodScan.query.filter_by(scan_id=log.scan_id).first()
                if scan and scan.image_path:
                    image_url = build_scan_image_url(scan.image_path)
                    
            unique_foods[key] = {
                "source": "my_foods",
                "log_id": log.id,
                "food_name": log.food_name,
                "calories": log.calories,
                "protein": log.protein,
                "carbs": log.carbs,
                "fats": log.fats,
                "serving_size": log.serving_size,
                "serving_name": log.serving_name,
                "scan_id": log.scan_id,
                "image_url": image_url,
                "last_used_at": (
                    log.log_time.strftime("%Y-%m-%d %H:%M:%S") if log.log_time else None
                ),
            }

        if len(unique_foods) >= limit:
            break

    return list(unique_foods.values())


def search_saved_scans(user_id, query, limit):
    scans_query = FoodScan.query.filter_by(user_id=user_id)

    scans_query = scans_query.filter(FoodScan.meal_name.isnot(None))

    if query:
        scans_query = scans_query.filter(FoodScan.meal_name.ilike(f"%{query}%"))

    scans = scans_query.order_by(FoodScan.created_at.desc()).limit(limit).all()

    return [
        {
            "source": "saved_scans",
            "scan_id": scan.scan_id,
            "food_name": scan.meal_name,
            "meal_name": scan.meal_name,
            "calories": scan.calories,
            "protein": scan.protein,
            "carbs": scan.carbs,
            "fats": scan.fat,
            "image_path": scan.image_path,
            "health_score": scan.health_score,
            "created_at": (
                scan.created_at.strftime("%Y-%m-%d %H:%M:%S")
                if scan.created_at
                else None
            ),
            "analyzed_at": (
                scan.analyzed_at.strftime("%Y-%m-%d %H:%M:%S")
                if scan.analyzed_at
                else None
            ),
        }
        for scan in scans
    ]


@user_bp.route("/food/search", methods=["GET"])
def search_food():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    tab = request.args.get("tab", "all").lower().strip()
    query = request.args.get("query", "").strip()
    limit = parse_limit(default=20, maximum=30)

    tab_aliases = {
        "all": "all",
        "my_meals": "my_meals",
        "my-meals": "my_meals",
        "my meals": "my_meals",
        "my_foods": "my_foods",
        "my-foods": "my_foods",
        "my foods": "my_foods",
        "saved_scans": "saved_scans",
        "saved-scans": "saved_scans",
        "saved scans": "saved_scans",
    }

    tab = tab_aliases.get(tab, "all")

    try:
        if tab == "all":
            search_query = query or ""
            if not search_query:
                results = search_my_foods(user["id"], "", limit)
                return jsonify({"tab": tab, "query": query, "count": len(results), "results": results}), 200

            try:
                off_results = search_open_food_facts(search_query, limit)
                if off_results:
                    results = off_results
                    external_service = "open_food_facts"
                    external_status_code = 200
                else:
                    raise Exception("Empty results")
            except Exception:
                # Fallback to USDA if Open Food Facts fails or returns nothing
                usda_response = search_usda_food_data(search_query, limit)
                if not usda_response.get("external_error") and usda_response.get("results"):
                    results = usda_response.get("results", [])
                    external_service = "usda_fdc"
                    external_status_code = usda_response.get("status_code")
                else:
                    results = []
                    external_service = "open_food_facts/usda_fdc"
                    external_status_code = usda_response.get("status_code")

            # Local / Mock database search fallback if external APIs returned nothing
            if not results:
                local_results = search_my_foods(user["id"], search_query, limit)
                if local_results:
                    results = local_results
                    external_service = "local_database"
                    external_status_code = 200
                else:
                    mock_db = [
                        {"food_name": "Croissant", "calories": 406, "protein": 8.2, "carbs": 45.8, "fats": 21.0, "serving_size": "1 piece (100g)", "serving_name": "piece", "source": "usda_fdc"},
                        {"food_name": "Apple", "calories": 52, "protein": 0.3, "carbs": 13.8, "fats": 0.2, "serving_size": "1 medium (182g)", "serving_name": "medium", "source": "usda_fdc"},
                        {"food_name": "Banana", "calories": 89, "protein": 1.1, "carbs": 22.8, "fats": 0.3, "serving_size": "1 medium (118g)", "serving_name": "medium", "source": "usda_fdc"},
                        {"food_name": "Chicken Breast", "calories": 165, "protein": 31.0, "carbs": 0.0, "fats": 3.6, "serving_size": "100g", "serving_name": "g", "source": "usda_fdc"},
                        {"food_name": "White Rice", "calories": 130, "protein": 2.7, "carbs": 28.0, "fats": 0.3, "serving_size": "1 cup (158g)", "serving_name": "cup", "source": "usda_fdc"},
                        {"food_name": "Whole Milk", "calories": 149, "protein": 7.7, "carbs": 11.7, "fats": 7.9, "serving_size": "1 cup (244g)", "serving_name": "cup", "source": "usda_fdc"},
                        {"food_name": "Egg", "calories": 155, "protein": 13.0, "carbs": 1.1, "fats": 11.0, "serving_size": "1 large (50g)", "serving_name": "large", "source": "usda_fdc"},
                    ]
                    for mock_item in mock_db:
                        if search_query.lower() in mock_item["food_name"].lower():
                            results.append(mock_item)
                    if results:
                        external_service = "mock_database"
                        external_status_code = 200
                    else:
                        external_service = "none"
                        external_status_code = 404

        elif tab == "my_meals":
            results = search_my_meals(user["id"], query, limit)

        elif tab == "my_foods":
            results = search_my_foods(user["id"], query, limit)

        elif tab == "saved_scans":
            results = search_saved_scans(user["id"], query, limit)

        else:
            results = []

        response_body = {
            "tab": tab,
            "query": query,
            "count": len(results),
            "results": results,
        }

        if tab == "all":
            response_body["external_service"] = external_service
            response_body["external_status_code"] = external_status_code

        return jsonify(response_body), 200

    except requests.exceptions.Timeout:
        return (
            jsonify(
                {
                    "message": "Food database request timed out",
                    "tab": tab,
                    "query": query,
                    "results": [],
                }
            ),
            504,
        )

    except Exception as e:
        return (
            jsonify(
                {
                    "message": "Food search failed",
                    "error": str(e),
                    "tab": tab,
                    "query": query,
                    "results": [],
                }
            ),
            500,
        )


# ---------------- Serving Database ----------------
@user_bp.route("/food/database/serving", methods=["GET"])
def get_database_serving_details():
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    source = request.args.get("source", "").strip()
    barcode = request.args.get("barcode")
    scan_id = request.args.get("scan_id")
    log_id = request.args.get("log_id")
    fdc_id = request.args.get("fdc_id")

    if source == "usda_fdc":
        if not fdc_id:
            return jsonify({"message": "fdc_id is required"}), 400

        food = get_usda_food_details(fdc_id)

        if not food:
            return jsonify({"message": "USDA food item not found"}), 404

        return jsonify(build_usda_serving_details(food)), 200

    if source == "open_food_facts":
        if not barcode:
            return jsonify({"message": "barcode is required"}), 400

        product = get_open_food_facts_product(barcode)

        if not product:
            return jsonify({"message": "Product not found"}), 404

        details = build_open_food_serving_details(product)

        return jsonify(details), 200

    if source == "saved_scans":
        if not scan_id:
            return jsonify({"message": "scan_id is required"}), 400

        scan = FoodScan.query.filter_by(scan_id=scan_id, user_id=user["id"]).first()

        if not scan:
            return jsonify({"message": "Scan not found"}), 404

        return (
            jsonify(
                {
                    "food": {
                        "source": "saved_scans",
                        "scan_id": scan.scan_id,
                        "food_name": scan.meal_name,
                        "calories": scan.calories,
                        "protein": scan.protein,
                        "carbs": scan.carbs,
                        "fats": scan.fat,
                        "image_path": scan.image_path,
                        "health_score": scan.health_score,
                    },
                    "servings": [
                        {
                            "serving_name": "1 serving",
                            "grams": None,
                            "calories": scan.calories,
                            "protein": scan.protein,
                            "carbs": scan.carbs,
                            "fats": scan.fat,
                        }
                    ],
                    "nutrition_facts": safe_json_loads(scan.full_report),
                }
            ),
            200,
        )

    if source in ["my_meals", "my_foods"]:
        if not log_id:
            return jsonify({"message": "log_id is required"}), 400

        log = UserFoodLog.query.filter_by(id=log_id, user_id=user["id"]).first()

        if not log:
            return jsonify({"message": "Food log not found"}), 404

        return (
            jsonify(
                {
                    "food": {
                        "source": source,
                        "log_id": log.id,
                        "food_name": log.food_name,
                        "calories": log.calories,
                        "protein": log.protein,
                        "carbs": log.carbs,
                        "fats": log.fats,
                        "serving_size": log.serving_size,
                        "serving_name": log.serving_name,
                    },
                    "servings": [
                        {
                            "serving_name": log.serving_name or "1 serving",
                            "grams": log.serving_size,
                            "calories": log.calories,
                            "protein": log.protein,
                            "carbs": log.carbs,
                            "fats": log.fats,
                        }
                    ],
                    "nutrition_facts": safe_json_loads(log.full_report),
                }
            ),
            200,
        )

    return jsonify({"message": "Invalid source"}), 400


@user_bp.route("/food/open-food-facts/<barcode>", methods=["GET"])
def get_open_food_facts_details(barcode):
    user, error_response, status_code = get_current_user()

    if error_response:
        return error_response, status_code

    product = get_open_food_facts_product(barcode)

    if not product:
        return jsonify({"message": "Product not found"}), 404

    return jsonify(build_open_food_serving_details(product)), 200


# ---------------- Weight Logging & History ----------------
@user_bp.route("/weight/log", methods=["POST"])
def log_weight():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    data = request.get_json() or {}
    weight_val = data.get("weight")
    date_str = data.get("date")

    if weight_val is None:
        return jsonify({"message": "weight is required"}), 400

    try:
        weight = float(weight_val)
    except ValueError:
        return jsonify({"message": "weight must be a number"}), 400

    log_date = date.today()
    if date_str:
        date_str = str(date_str).strip()
        for fmt in ("%Y-%m-%d", "%m/%d/%y", "%m/%d/%Y", "%d/%m/%Y"):
            try:
                log_date = datetime.strptime(date_str, fmt).date()
                break
            except ValueError:
                continue

    existing_log = UserWeightLog.query.filter_by(user_id=user["id"], log_date=log_date).first()
    if existing_log:
        existing_log.weight = weight
    else:
        new_log = UserWeightLog(user_id=user["id"], weight=weight, log_date=log_date)
        db.session.add(new_log)

    latest_log = UserWeightLog.query.filter_by(user_id=user["id"]).order_by(UserWeightLog.log_date.desc()).first()
    if latest_log and latest_log.log_date >= log_date:
        new_latest_weight = latest_log.weight
    else:
        new_latest_weight = weight

    db.session.execute(
        text("UPDATE users SET weight = :weight WHERE id = :id"),
        {"weight": new_latest_weight, "id": user["id"]}
    )

    db.session.commit()

    return jsonify({"message": "Weight logged successfully", "weight": weight, "date": log_date.strftime("%Y-%m-%d")}), 201


@user_bp.route("/weight/history", methods=["GET"])
def get_weight_history():
    user, error_response, status_code = get_current_user()
    if error_response:
        return error_response, status_code

    logs = UserWeightLog.query.filter_by(user_id=user["id"]).order_by(UserWeightLog.log_date.desc()).all()
    return jsonify({"logs": [log.to_dict() for log in logs]}), 200