import os
from dotenv import load_dotenv

# Walk up directory tree to load .env if it exists
current_dir = os.path.dirname(os.path.abspath(__file__))
loaded_env = False
while current_dir != os.path.dirname(current_dir):
    env_path = os.path.join(current_dir, '.env')
    if os.path.exists(env_path):
        load_dotenv(env_path)
        loaded_env = True
        break
    current_dir = os.path.dirname(current_dir)

if not loaded_env:
    load_dotenv()


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key")
    SQLALCHEMY_DATABASE_URI = "sqlite:///calai.db"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
    UPLOAD_FOLDER = os.getenv("UPLOAD_FOLDER", "uploads")
    FDC_API_KEY = os.getenv("FDC_API_KEY")
