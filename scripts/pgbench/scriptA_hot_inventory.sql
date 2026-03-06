-- sacamos un cliente aleatorio (1 a 599) y un staff (1 o 2)
\set customer random(1, 599)
\set staff random(1, 2)

BEGIN;

-- bloqueamos el inventario 1 para que nadie más lo agarre al mismo tiempo
SELECT inventory_id FROM inventory WHERE inventory_id = 1 FOR UPDATE;

-- metemos la renta solo si el disco no está rentado actualemnte
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
SELECT NOW(), 1, :customer, :staff
WHERE NOT EXISTS (
    SELECT 1 FROM rental 
    WHERE inventory_id = 1 AND return_date IS NULL
);

COMMIT;