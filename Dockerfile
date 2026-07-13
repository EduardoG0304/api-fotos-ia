FROM python:3.9

WORKDIR /app

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    libx11-dev \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# --- AQUÍ ESTÁ LA SOLUCIÓN AL ERROR DE MEMORIA ---
# Estas dos variables obligan al servidor a usar un solo núcleo de procesamiento
# durante la instalación de dlib. Esto evita el pico de consumo de RAM.
ENV CMAKE_BUILD_PARALLEL_LEVEL=1
ENV MAKEFLAGS="-j1"

COPY requirements.txt .

# Primero instalamos solo dlib de forma aislada, sin usar caché de disco
RUN pip install --no-cache-dir dlib==19.24.2

# Luego instalamos el resto de tus librerías
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Render asigna automáticamente un puerto, le decimos a FastAPI que lo escuche
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port ${PORT:-10000}"]