# 1) Base con Python 3.11 (estable para FastAPI/Sklearn)
FROM python:3.11-slim

# 2) Ajustes de Python/pip
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 3) Directorio de trabajo
WORKDIR /app

# 4) Dependencias de sistema (libgomp1 útil si usas xgboost)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libgomp1 \
  && rm -rf /var/lib/apt/lists/*

# 5) Instala requirements primero (mejor cache)
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# 6) Copia el resto de la app (incluye tu .pkl)
COPY . .

# 7) (Opcional) expone 8080; Cloud Run usa $PORT igualmente
EXPOSE 8080

# 8) Arranque con gunicorn + uvicorn; bind a $PORT (Cloud Run lo setea)
CMD ["sh", "-c", "gunicorn -k uvicorn.workers.UvicornWorker -w 2 -b 0.0.0.0:$PORT --log-level debug --error-logfile - --access-logfile - main:app"]
