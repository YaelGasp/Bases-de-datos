-- definimos el orden: la mitad de los procesos agarra 1->2 y la otra mitad 2->1
\set c1 1 + (:client_id % 2)
\set c2 2 - (:client_id % 2)

BEGIN;

-- aseguramos el primer registro para que nadie mas lo toque
SELECT * FROM customer WHERE customer_id = :c1 FOR UPDATE;

-- nos dormimos un segundo completo para obligar a que los hilos se crucen
SELECT pg_sleep(1);

-- intentamos agarrar el registro cruzado (aqui va a tronar si o si)
SELECT * FROM customer WHERE customer_id = :c2 FOR UPDATE;

COMMIT;