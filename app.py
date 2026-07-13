from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel
import requests
import numpy as np
import cv2
import easyocr
import face_recognition
import os

app = FastAPI()
reader = easyocr.Reader(['en'], gpu=False)

class ImageRequest(BaseModel):
    imageUrl: str

@app.get("/")
def read_root():
    return {"status": "API IA Activa en Render"}

@app.post("/analizar")
def analizar_imagen(req: ImageRequest, authorization: str = Header(None)):
    api_key = os.environ.get("SECRET_API_KEY", "mi_clave_123")
    
    if authorization != f"Bearer {api_key}":
        raise HTTPException(status_code=401, detail="No autorizado")

    try:
        resp = requests.get(req.imageUrl)
        if resp.status_code != 200:
            raise HTTPException(status_code=400, detail="Error descargando imagen")
        
        image_bytes = np.asarray(bytearray(resp.content), dtype="uint8")
        img = cv2.imdecode(image_bytes, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Formato inválido")

        # Dorsales
        text_results = reader.readtext(img, detail=0)
        dorsales = [t for t in text_results if t.isdigit()]

        # Rostros
        rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_img)
        face_encodings = face_recognition.face_encodings(rgb_img, face_locations)

        rostros = [encoding.tolist() for encoding in face_encodings]

        return {
            "dorsales": list(set(dorsales)),
            "rostros": rostros
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))