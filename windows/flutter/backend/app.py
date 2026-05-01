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
from flask import Flask
from config import Config
from extensions import db
from routes.auth_routes import auth_bp
from routes.user_routes import user_bp

app = Flask(__name__)
app.config.from_object(Config)

# Initialize extensions
db.init_app(app)

# Register Blueprints
app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(user_bp, url_prefix='/user')

if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # ده بيعمل الـ tables لأول مرة
    
    # Logic: host='0.0.0.0' allows external devices (like your phone) to connect
    # Port 5000 matches your Flutter baseUrl
    app.run(debug=True, host='0.0.0.0', port=5000)