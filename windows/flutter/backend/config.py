import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key")
    SQLALCHEMY_DATABASE_URI = "sqlite:///calai.db"
    SQLALCHEMY_TRACK_MODIFICATIONS = False