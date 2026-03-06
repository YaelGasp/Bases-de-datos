from fastapi import FastAPI

app = FastAPI(title="DVD Rental API")

@app.get("/")
def root():
    return {"message": "DVD Rental API funcionando"}

import time
from datetime import datetime
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import OperationalError
from pydantic import BaseModel

# Importamos la configuración de la base de datos y los modelos del equipo
from database import get_db
import models

# Esquema de validación para recibir los datos de la renta en la API
class RentalCreate(BaseModel):
    inventory_id: int
    customer_id: int
    staff_id: int

# AREA 1: ENDPOINTS DE RENTAS 
@app.post("/rentals")
def create_rental(rental: RentalCreate, db: Session = Depends(get_db)):
    intentos = 3
    
    for i in range(intentos):
        try:
            # Aplicamos bloqueo pesimista (FOR UPDATE) visto en clase
            # Bloqueamos el item en el inventario para evitar problemas de concurrencia
            item = db.query(models.Inventory).filter(
                models.Inventory.inventory_id == rental.inventory_id
            ).with_for_update().first()

            if not item:
                raise HTTPException(status_code=404, detail="El item no existe en el inventario")

            # creamos el registro de la nueva renta
            nueva_renta = models.Rental(
                rental_date=datetime.now(),
                inventory_id=rental.inventory_id,
                customer_id=rental.customer_id,
                staff_id=rental.staff_id
            )
            db.add(nueva_renta)
            db.commit()
            db.refresh(nueva_renta)
            
            return {"status": "success", "rental_id": nueva_renta.rental_id}

        except OperationalError as e:
            db.rollback()
            # Verificamos si el error fue causado por un deadlock 
            if "deadlock detected" in str(e).lower() and i < intentos - 1:
                time.sleep(1) # Esperamos y reintentamos
                continue
            # Si se acaban los intentos o es otro error de base de datos
            raise HTTPException(status_code=500, detail="El servidor experimenta alta concurrencia, intente de nuevo")
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=400, detail=str(e))

# AREA 1: ENDPOINT DE DEVOLUCIONES
@app.put("/returns/{rental_id}")
def process_return(rental_id: int, db: Session = Depends(get_db)):
    try:
        # Buscamos la renta y la bloqueamos para actualizar su estado
        renta = db.query(models.Rental).filter(
            models.Rental.rental_id == rental_id
        ).with_for_update().first()

        if not renta:
            raise HTTPException(status_code=404, detail="Renta no encontrada")
        
        if renta.return_date:
            raise HTTPException(status_code=400, detail="Esta película ya ha sido devuelta")

        # registramos la fecha y hora actual de la devolucion
        renta.return_date = datetime.now()
        db.commit()
        return {"status": "success", "message": "Devolución registrada correctamente"}
        
    except OperationalError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Error de concurrencia al procesar la devolución")
    