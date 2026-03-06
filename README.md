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