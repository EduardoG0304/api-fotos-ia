FROM debian:bullseye-slim

WORKDIR /app

# 1. Instalamos Python, pip y las librerías precompiladas del sistema.
# 'python3-dlib' es la clave mágica: instala dlib precompilado en segundos sin usar RAM.
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dlib \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    libx11-dev \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# 2. Instalamos tus dependencias de Python.
# Pip detectará que dlib ya está instalado a nivel de sistema operativo y no intentará compilarlo.
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 3. Arrancamos el servidor
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port ${PORT:-10000}"]