from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime, date
from database import get_db
import models

enrutador = APIRouter()

class EntradaPago(BaseModel):
    customer_id: int
    staff_id: int
    amount: float
    rental_id: int

@enrutador.post("/payments")
def registrar_pago(datos: EntradaPago, db: Session = Depends(get_db)):
    
    # Validar que el cliente existe
    cliente = db.query(models.Customer).filter(models.Customer.customer_id == datos.customer_id).first()
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    
    # Si viene rental_id, validar que existe y pertenece al cliente
    if datos.rental_id is not None:
        renta = db.query(models.Rental).filter(models.Rental.rental_id == datos.rental_id).first()
        if not renta:
            raise HTTPException(status_code=404, detail="Renta no encontrada")
        if renta.customer_id != datos.customer_id:
            raise HTTPException(status_code=400, detail="La renta no pertenece a este cliente")
    
    # Crear el pago
    nuevo_pago = models.Payment(
        customer_id=datos.customer_id,
        staff_id=datos.staff_id,
        rental_id=datos.rental_id,
        amount=datos.amount,
        payment_date=datetime(2022, 1, 15, 12, 0, 0)
    )
    
    db.add(nuevo_pago)
    db.commit()
    db.refresh(nuevo_pago)
    
    return {"mensaje": "Pago registrado exitosamente", "payment_id": nuevo_pago.payment_id}