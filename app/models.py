from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey, SmallInteger
from sqlalchemy.orm import relationship
from database import Base

class Customer(Base):
    __tablename__ = "customer"

    customer_id = Column(Integer, primary_key=True)
    store_id = Column(SmallInteger)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String)
    active = Column(Integer)
    rentals = relationship("Rental", back_populates="customer")
    payments = relationship("Payment", back_populates="customer")


class Inventory(Base):
    __tablename__ = "inventory"

    inventory_id = Column(Integer, primary_key=True)
    film_id = Column(SmallInteger)
    store_id = Column(SmallInteger)
    rentals = relationship("Rental", back_populates="inventory")


class Rental(Base):
    __tablename__ = "rental"

    rental_id = Column(Integer, primary_key=True)
    rental_date = Column(DateTime(timezone=True))
    inventory_id = Column(Integer, ForeignKey("inventory.inventory_id"))
    customer_id = Column(Integer, ForeignKey("customer.customer_id"))
    return_date = Column(DateTime(timezone=True), nullable=True)
    staff_id = Column(SmallInteger)
    customer = relationship("Customer", back_populates="rentals")
    inventory = relationship("Inventory", back_populates="rentals")
    payments = relationship("Payment", back_populates="rental")


class Payment(Base):
    __tablename__ = "payment"

    payment_id = Column(Integer, primary_key=True)
    customer_id = Column(Integer, ForeignKey("customer.customer_id"))
    staff_id = Column(SmallInteger)
    rental_id = Column(Integer, ForeignKey("rental.rental_id"), nullable=False)
    amount = Column(Numeric(5, 2))
    payment_date = Column(DateTime(timezone=True))
    customer = relationship("Customer", back_populates="payments")
    rental = relationship("Rental", back_populates="payments")