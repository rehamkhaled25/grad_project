# app.py
from flask import Flask
from config import Config
from extensions import db
from routes.auth_routes import auth_bp
from routes.user_routes import user_bp
from routes.food_routes import food_bp  # <-- تم إضافة الـ food routes
from flask_migrate import Migrate

# Initialize app
app = Flask(__name__)
app.config.from_object(Config)

# Initialize extensions
db.init_app(app)
migrate = Migrate(app, db)

# Register Blueprints
app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(user_bp, url_prefix='/user')
app.register_blueprint(food_bp, url_prefix='/food')  # <-- تسجيل الـ food routes

if __name__ == '__main__':
    app.run(debug=True)