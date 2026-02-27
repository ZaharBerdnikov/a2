#!/bin/bash
set -e

echo "========================================="
echo "ComfyUI Docker Container"
echo "========================================="

# Устанавливаем недостающие зависимости (если не установлены)
python3.11 -m pip install sqlalchemy alembic --quiet 2>/dev/null || true

# Загружаем модели если указаны
if [ ! -z "$MODELS_TO_DOWNLOAD" ]; then
    echo ""
    echo "Загрузка моделей..."
    python3.11 /app/download_models.py
fi

echo ""
echo "Запуск ComfyUI..."
echo "Доступен на: http://localhost:$COMFYUI_PORT"
echo ""

# Запускаем ComfyUI
exec "$@"
