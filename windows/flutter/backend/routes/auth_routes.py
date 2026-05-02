from datetime import datetime, timedelta, timezone
import jwt
from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy import text

from extensions import db

auth_bp = Blueprint("auth", __name__)


def create_token(user_or_id):
    user_id = user_or_id.id if hasattr(user_or_id, "id") else int(user_or_id)
    payload = {
        "user_id": user_id,
        "exp": datetime.now(timezone.utc) + timedelta(days=7),
    }
    return jwt.encode(payload, current_app.config["SECRET_KEY"], algorithm="HS256")


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json() or {}
    full_name = data.get("full_name", "").strip()
    email = data.get("email", "").strip().lower()
    password = data.get("password", "").strip()

    if not full_name:
        return jsonify({"message": "Full name is required"}), 400
    if not email:
        return jsonify({"message": "Email is required"}), 400
    if not password or len(password) < 6:
        return jsonify({"message": "Password must be at least 6 characters"}), 400

    existing_user = db.session.execute(
        text("SELECT id FROM users WHERE email = :email"), {"email": email}
    ).fetchone()
    if existing_user:
        return jsonify({"message": "Email already exists"}), 409

    password_hash = generate_password_hash(password)
    db.session.execute(
        text(
            "INSERT INTO users (full_name, email, password_hash, created_at) "
            "VALUES (:full_name, :email, :password_hash, :created_at)"
        ),
        {"full_name": full_name, "email": email, "password_hash": password_hash,
         "created_at": datetime.utcnow()}
    )
    db.session.commit()

    # استرجاع اليوزر الجديد عشان نطلع له التوكن
    user = db.session.execute(
        text("SELECT id, full_name, email FROM users WHERE email = :email"),
        {"email": email}
    ).mappings().first()

    token = create_token(user["id"])
    return jsonify({
        "message": "User registered successfully",
        "token": token,
        "user": {
            "id": user["id"],
            "full_name": user["full_name"],
            "email": user["email"]
        }
    }), 201


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    email = data.get("email", "").strip().lower()
    password = data.get("password", "").strip()

    if not email or not password:
        return jsonify({"message": "Email and password are required"}), 400

    # هنا مش بنستخدم User model عشان ما يقرأش birthdate
    user = db.session.execute(
        text("SELECT id, full_name, email, password_hash FROM users WHERE email = :email LIMIT 1"),
        {"email": email}
    ).mappings().first()

    if not user or not check_password_hash(user["password_hash"], password):
        return jsonify({"message": "Invalid email or password"}), 401

    token = create_token(user["id"])
    return jsonify({
        "message": "Login successful",
        "token": token,
        "user": {
            "id": user["id"],
            "full_name": user["full_name"],
            "email": user["email"]
        }
    }), 200