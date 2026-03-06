-- Archivo: sql/queries.sql
-- Propósito: Consultas avanzadas de la BD Pagila

-- -----------------------------------------------------------------------------
-- Q1 — Top 10 clientes por gasto con ranking
-- Propósito: Obtener los 10 clientes que más han gastado históricamente, 
-- asignándoles una posición usando RANK().
-- -----------------------------------------------------------------------------
WITH CustomerSpending AS (
    SELECT 
        c.customer_id, 
        c.first_name, 
        c.last_name, 
        SUM(p.amount) AS total_paid
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    RANK() OVER (ORDER BY total_paid DESC) AS rank,
    customer_id,
    first_name,
    last_name,
    total_paid
FROM CustomerSpending
LIMIT 10;
-- Ejemplo salida: rank=1, customer_id=526, first_name=KARL, last_name=SEAL, total_paid=221.55


-- -----------------------------------------------------------------------------
-- Q2 — Top 3 películas por tienda (por # de rentas)
-- Propósito: Descubrir cuáles son las 3 películas más populares en cada 
-- sucursal usando particiones (Window Functions).
-- -----------------------------------------------------------------------------
WITH FilmRentals AS (
    SELECT 
        i.store_id, 
        f.film_id, 
        f.title, 
        COUNT(r.rental_id) AS rentals_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    GROUP BY i.store_id, f.film_id, f.title
),
RankedRentals AS (
    SELECT 
        store_id, 
        film_id, 
        title, 
        rentals_count,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY rentals_count DESC) AS rn
    FROM FilmRentals
)
SELECT store_id, film_id, title, rentals_count, rn
FROM RankedRentals
WHERE rn <= 3;
-- Ejemplo salida: store_id=1, film_id=103, title=BUCKET BROTHERHOOD, rentals_count=34, rn=1