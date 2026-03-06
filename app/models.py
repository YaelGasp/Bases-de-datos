from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, SmallInteger
from sqlalchemy.orm import relationship
from app.database import Base

class Cliente(Base):
    __tablename__ = "customer"

    customer_id = Column(Integer, primary_key=True)
    store_id = Column(SmallInteger)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String)
    active = Column(Integer)

    rentas = relationship("Renta", back_populates="cliente")
    pagos = relationship("Pago", back_populates="cliente")


class Inventario(Base):
    __tablename__ = "inventory"

    inventory_id = Column(Integer, primary_key=True)
    film_id = Column(SmallInteger)
    store_id = Column(SmallInteger)

    rentas = relationship("Renta", back_populates="inventario")


class Renta(Base):
    __tablename__ = "rental"

    rental_id = Column(Integer, primary_key=True)
    rental_date = Column(DateTime(timezone=True))
    inventory_id = Column(Integer, ForeignKey("inventory.inventory_id"))
    customer_id = Column(Integer, ForeignKey("customer.customer_id"))
    return_date = Column(DateTime(timezone=True), nullable=True)
    staff_id = Column(SmallInteger)

    cliente = relationship("Cliente", back_populates="rentas")
    inventario = relationship("Inventario", back_populates="rentas")
    pagos = relationship("Pago", back_populates="renta")


class Pago(Base):
    __tablename__ = "payment"

    payment_id = Column(Integer, primary_key=True)
    customer_id = Column(Integer, ForeignKey("customer.customer_id"))
    staff_id = Column(SmallInteger)
    rental_id = Column(Integer, ForeignKey("rental.rental_id"), nullable=True)
    amount = Column(Numeric(5, 2))
    payment_date = Column(DateTime(timezone=True))

    cliente = relationship("Cliente", back_populates="pagos")
    renta = relationship("Renta", back_populates="pagos")