FROM ubuntu:22.04

# Evita que el instalador de Ubuntu se pause pidiendo confirmaciones
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. Instalamos Python, pip y dlib directamente desde los repositorios oficiales de Ubuntu
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dlib \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 2. Hacemos que el comando 'python' apunte a 'python3' para mantener compatibilidad
RUN ln -s /usr/bin/python3 /usr/bin/python

COPY requirements.txt .

# 3. Instalamos tus dependencias
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 4. Arrancamos el servidor
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port ${PORT:-10000}"]