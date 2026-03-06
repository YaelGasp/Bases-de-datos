from fastapi import FastAPI

app = FastAPI(title="DVD Rental API")

@app.get("/")
def root():
    return {"message": "DVD Rental API funcionando"}

