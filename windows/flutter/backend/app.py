# # app.py
# from flask import Flask
# from config import Config
# from extensions import db
# from routes.auth_routes import auth_bp
# from routes.user_routes import user_bp

# app = Flask(__name__)
# app.config.from_object(Config)

# # Initialize extensions
# db.init_app(app)

# # Register Blueprints
# app.register_blueprint(auth_bp, url_prefix='/auth')
# app.register_blueprint(user_bp, url_prefix='/user')

# if __name__ == '__main__':
#     with app.app_context():
#         db.create_all()  # ده بيعمل الـ tables لأول مرة
#     app.run(debug=True)


# app.py
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

import requests
from requests.adapters import HTTPAdapter
original_send = HTTPAdapter.send
HTTPAdapter.send = lambda self, request, **kwargs: original_send(self, request, **{**kwargs, 'verify': False})

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
app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(user_bp, url_prefix="/user")
app.register_blueprint(food_bp, url_prefix="/food")  # <-- تسجيل الـ food routes

if __name__ == "__main__":
    with app.app_context():
        db.create_all()

    app.run(debug=True, host="0.0.0.0", port=5000)
