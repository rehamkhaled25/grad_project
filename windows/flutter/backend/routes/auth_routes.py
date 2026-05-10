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


def to_float(value):
    if value is None or value == "":
        return None
    return float(value)


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

    return [
        item.strip()
        for item in str(allergies_text).split(",")
        if item.strip()
    ]


def user_response(user):
    return {
        "id": user["id"],
        "full_name": user["full_name"],
        "email": user["email"],
        "birthdate": user["birthdate"],
        "gender": user["gender"],
        "goal": user["goal"],
        "weight": user["weight"],
        "height": user["height"],
        "goal_weight": user["goal_weight"],
        "allergies": allergies_to_list(user["allergies"]),
    }


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
        text("SELECT id FROM users WHERE email = :email"),
        {"email": email}
    ).fetchone()

    if existing_user:
        return jsonify({"message": "Email already exists"}), 409

    try:
        birthdate = data.get("birthdate") or None
        gender = data.get("gender") or None
        goal = data.get("goal") or None
        weight = to_float(data.get("weight"))
        height = to_float(data.get("height"))
        goal_weight = to_float(data.get("goal_weight"))
        allergies = allergies_to_text(data.get("allergies"))
    except ValueError:
        return jsonify({
            "message": "weight, height, and goal_weight must be numbers"
        }), 400

    password_hash = generate_password_hash(password)

    db.session.execute(
        text(
            """
            INSERT INTO users (
                full_name,
                email,
                password_hash,
                birthdate,
                gender,
                goal,
                weight,
                height,
                goal_weight,
                allergies,
                created_at
            )
            VALUES (
                :full_name,
                :email,
                :password_hash,
                :birthdate,
                :gender,
                :goal,
                :weight,
                :height,
                :goal_weight,
                :allergies,
                :created_at
            )
            """
        ),
        {
            "full_name": full_name,
            "email": email,
            "password_hash": password_hash,
            "birthdate": birthdate,
            "gender": gender,
            "goal": goal,
            "weight": weight,
            "height": height,
            "goal_weight": goal_weight,
            "allergies": allergies,
            "created_at": datetime.utcnow(),
        }
    )

    db.session.commit()

    user = db.session.execute(
        text(
            """
            SELECT
                id,
                full_name,
                email,
                birthdate,
                gender,
                goal,
                weight,
                height,
                goal_weight,
                allergies
            FROM users
            WHERE email = :email
            LIMIT 1
            """
        ),
        {"email": email}
    ).mappings().first()

    token = create_token(user["id"])

    return jsonify({
        "message": "User registered successfully",
        "token": token,
        "user": user_response(user)
    }), 201


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}

    email = data.get("email", "").strip().lower()
    password = data.get("password", "").strip()

    if not email or not password:
        return jsonify({"message": "Email and password are required"}), 400

    user = db.session.execute(
        text(
            """
            SELECT
                id,
                full_name,
                email,
                password_hash,
                birthdate,
                gender,
                goal,
                weight,
                height,
                goal_weight,
                allergies
            FROM users
            WHERE email = :email
            LIMIT 1
            """
        ),
        {"email": email}
    ).mappings().first()

    if not user or not check_password_hash(user["password_hash"], password):
        return jsonify({"message": "Invalid email or password"}), 401

    token = create_token(user["id"])

    return jsonify({
        "message": "Login successful",
        "token": token,
        "user": user_response(user)
    }), 200