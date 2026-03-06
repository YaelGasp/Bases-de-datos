from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os

load_dotenv()

servidor = os.getenv("DB_HOST")
puerto = os.getenv("DB_PORT")
nombre_base = os.getenv("DB_NAME")
usuario = os.getenv("DB_USER")
contrasena = os.getenv("DB_PASSWORD")

url_conexion = f"postgresql://{usuario}:{contrasena}@{servidor}:{puerto}/{nombre_base}"

motor = create_engine(url_conexion)
SesionLocal = sessionmaker(bind=motor)
Base = declarative_base()

def obtener_db():
    sesion = SesionLocal()
    try:
        yield sesion
    finally:
        sesion.close()