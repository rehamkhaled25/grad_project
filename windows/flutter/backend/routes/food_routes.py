from flask import Blueprint, request, jsonify
import os

food_bp = Blueprint('food_bp', __name__)
UPLOAD_FOLDER = "backend/uploads"

# تأكد إن فولدر الرفع موجود
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# 1️⃣ Camera - رفع الصورة
@food_bp.route("/upload_food_image", methods=["POST"])
def upload_food_image():
    user_id = request.form.get("user_id")
    file = request.files.get("image_file")
    if file:
        file_path = os.path.join(UPLOAD_FOLDER, f"{user_id}_{file.filename}")
        file.save(file_path)
        return jsonify({"image_url": file_path, "message": "Image uploaded successfully"})
    return jsonify({"error": "No file uploaded"}), 400

# 2️⃣ Analysis - تحليل الصورة بالـ AI
@food_bp.route("/analyze", methods=["POST"])
def analyze():
    data = request.json
    image_url = data.get("image_url")
    user_id = data.get("user_id")

    # هنا استدعي الـ AI model
    # مثال: result = ai_model.predict(image_url)
    result = {
        "food_name": "Apple",
        "calories": 95,
        "carbs": 25,
        "protein": 0.5,
        "fat": 0.3
    }
    return jsonify(result)

# 3️⃣ Log Food - تسجيل الوجبة
@food_bp.route("/log_food", methods=["POST"])
def log_food():
    data = request.json
    user_id = data.get("user_id")
    food_name = data.get("food_name")
    quantity = data.get("quantity")
    calories = data.get("calories")
    timestamp = data.get("timestamp")

    # حفظ البيانات في قاعدة البيانات
    # db.execute("INSERT INTO food_logs ...")
    return jsonify({"message": "Meal logged successfully"})

# 4️⃣ Food Database Search
@food_bp.route("/search_food", methods=["GET"])
def search_food():
    query = request.args.get("query")
    # البحث في قاعدة البيانات
    # results = db.execute("SELECT food_name, calories FROM food_database WHERE food_name LIKE ?", (f"%{query}%",)).fetchall()
    results = [{"food_name": "Apple", "calories": 95}, {"food_name": "Apple Pie", "calories": 300}]
    return jsonify(results)

# 5️⃣ Serving Database
@food_bp.route("/serving_database", methods=["GET"])
def serving_database():
    food = request.args.get("food")
    # استرجاع الحصص من قاعدة البيانات
    # results = db.execute("SELECT serving_name, grams, calories FROM servings WHERE food_name = ?", (food,)).fetchall()
    results = [
        {"serving_name": "Small", "grams": 100, "calories": 52},
        {"serving_name": "Medium", "grams": 150, "calories": 78},
        {"serving_name": "Large", "grams": 200, "calories": 104}
    ]
    return jsonify(results)