-- Q1 — Top 10 clientes por gasto con ranking
-- Vamos a obtener los 10 clientes que más han gastado y que posicion tienen en el ranking.
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


-- Q2 — Top 3 películas por tienda (por # de rentas)
-- Queremos descubrir cuáles son las 3 películas más rentadas en cada sucursal.
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

-- Q3 - Inventario disponible por tienda (CTE)
-- Lo que vamos a hacer es calcular cuantos items tenemos por tienda y que se puedan rentar
WITH ActiveRentals AS (
    SELECT inventory_id
    FROM rental
    WHERE return_date IS NULL
)
SELECT
    i.store_id,
    COUNT(i.inventory_id) AS available_inventory_count
FROM inventory i
LEFT JOIN ActiveRentals ar ON i.inventory_id = ar.inventory_id
WHERE ar.inventory IS NULL 
GROUP BY i.store_id;


-- Q4 - Análisis de retrasos: rentas tardias agregadas por categoría (CTE)
-- Lo que queremos hacer es mostrar por categorías de peliculas cuantas son rentas tardias y cuanto es su retrso de días
WITH LateRentals AS (
    SELECT
        r.rental_id,
        i.film_id,
        DATE_PART('day', r.return_date - r.rental_date) - f.rental_duration AS days_late
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    Join film f ON i.film_id = f.film_id
    WHERE r.return_date IS NOT NULL 
      AND r.return_date > r.rental_date + (f.rental_duration * INTERVAL '1 day')
)
SELECT 
    c.category_id,
    c.name AS category_name,
    COUNT(lr.rental_id) AS late_rentals,
    ROUND(AVG(lr.days_late)::numeric, 2) AS avg_days_late
FROM LateRentals lr
JOIN film_category fc ON lr.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name
ORDER BY late_rentals DESC;
