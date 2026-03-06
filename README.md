# Proyecto Intersemestral - DVD Rental (Pagila)

Sistema de renta de películas usando PostgreSQL, SQLAlchemy y FastAPI.

## Guía de Instalación Local

1. **Clonar repositorio:**
   `git clone https://github.com/YaelGasp/Bases-de-datos.git`

2. **Base de Datos (PostgreSQL 18):**
   - Crear base de datos: `createdb pagila`
   - Cargar datos: `psql -d pagila -f pagila.sql`

3. **Entorno Python:**
   - Instalar dependencias: `pip install -r requirements.txt`

## Pruebas de Concurrencia (pgbench)

Ejecutar estos comandos para validar la seguridad transaccional:

- **Hot Inventory:** `& "C:\Program Files\PostgreSQL\18\bin\pgbench.exe" -U postgres -d pagila -c 20 -j 4 -T 30 -f scripts/pgbench/scriptA_hot_inventory.sql`
- **Deadlock:** `& "C:\Program Files\PostgreSQL\18\bin\pgbench.exe" -U postgres -d pagila -c 20 -j 4 -T 30 -f scripts/pgbench/scriptB_deadlock.sql`

## Configuración del archivo .env

Crea un archivo `.env` dentro de la carpeta `app/` con estos valores:

DB_HOST=localhost
DB_PORT=5432
DB_NAME=pagila
DB_USER=postgres
DB_PASSWORD=tu_contraseña

## Correr la API

1. Entrar a la carpeta app:
   cd app

2. Iniciar el servidor:
   python -m uvicorn main:app --reload

3. Abrir el navegador en:
   - API: `http://127.0.0.1:8000`
   - Documentación interactiva: `http://127.0.0.1:8000/docs`

## Endpoints disponibles

- `GET /` — Verificar que la API está corriendo
- `POST /rentals` — Crear una nueva renta
- `PUT /returns/{rental_id}` — Registrar devolución de una renta
- `POST /payments` — Registrar un pago