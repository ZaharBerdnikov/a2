FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV COMFYUI_PORT=8188

# Устанавливаем Python 3.11 и необходимые пакеты
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем pip для Python 3.11
RUN wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && \
    python3.11 /tmp/get-pip.py && \
    rm /tmp/get-pip.py && \
    python3.11 -m pip install --upgrade pip setuptools wheel

# Устанавливаем рабочую директорию
WORKDIR /app

# Клонируем ComfyUI
RUN git clone https://github.com/Comfy-Org/ComfyUI.git .

# Устанавливаем зависимости в правильном порядке:
# 1. Сначала PyTorch с CUDA
RUN python3.11 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 2. Устанавливаем дополнительные зависимости ComfyUI
RUN python3.11 -m pip install sqlalchemy alembic aiohttp pillow scipy

# 3. Устанавливаем остальные зависимости из requirements.txt
RUN python3.11 -m pip install -r requirements.txt

# Создаем папки для моделей и данных
RUN mkdir -p models/checkpoints models/loras models/controlnet models/vae models/embeddings models/clip models/unet models/clip_vision input output

# Скрипт для скачивания моделей
COPY download_models.py /app/download_models.py
RUN chmod +x /app/download_models.py

# Скрипт запуска
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Открываем порт
EXPOSE 8188

# Точка входа
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["python3.11", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
