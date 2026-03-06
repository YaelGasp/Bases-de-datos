-- 7.1 Trigger de auditoría
-- Creamos la tabla de log
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id SERIAL PRIMARY KEY,
    event_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    table_name VARCHAR(50) NOT NULL,
    op VARCHAR(10) NOT NULL,
    pk INTEGER NOT NULL,
    old_row JSONB,
    new_row JSONB
);

-- Creamos la función del trigger de auditoría
CREATE OR REPLACE FUNCTION audit_rental_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (table_name, op, pk, old_row, new_row)
        VALUES (TG_TABLE_NAME, TG_OP, OLD.rental_id, to_jsonb(OLD), NULL);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (table_name, op, pk, old_row, new_row)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.rental_id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (table_name, op, pk, old_row, new_row)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.rental_id, NULL, to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Creaamos el Trigger y asociamos a la tabla rental
DROP TRIGGER IF EXISTS trg_audit_rental ON rental;
CREATE TRIGGER trg_audit_rental
AFTER INSERT OR UPDATE OR DELETE ON rental
FOR EACH ROW EXECUTE FUNCTION audit_rental_changes();

-- 7.2 Trigger de regla de negocio, vamos a impedir pago <= 0 o fuera de rango permitido.
-- Creamos la función de validación
CREATE OR REPLACE FUNCTION check_valid_payment()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar monto mayor a 0 
    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'No se permiten pagos con monto menor o igual a cero. Monto intentado: %', NEW.amount;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creamos el Trigger
DROP TRIGGER IF EXISTS trg_check_payment ON payment;
CREATE TRIGGER trg_check_payment
BEFORE INSERT OR UPDATE ON payment
FOR EACH ROW EXECUTE FUNCTION check_valid_payment();