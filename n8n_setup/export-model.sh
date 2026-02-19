#!/bin/bash

# Скрипт для подготовки модели для офлайн-использования
# Выполняется ОДИН РАЗ на машине с интернетом
# Создает локальную копию модели в embedders/

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="${OLLAMA_MODEL:-nomic-embed-text}"
EMBEDDERS_DIR="$SCRIPT_DIR/embedders"
TEMP_VOLUME="ollama_export_$(date +%s)"

echo "=============================================="
echo "  Экспорт модели для офлайн-использования"
echo "=============================================="
echo ""
echo "Модель: $MODEL"
echo "Целевая директория: $EMBEDDERS_DIR"
echo ""

# Проверка наличия docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker не установлен${NC}"
    exit 1
fi

# Загрузка образа Ollama
if ! docker images | grep -q "ollama/ollama"; then
    echo "Загрузка образа Ollama..."
    if [ -f "$SCRIPT_DIR/docker_images/ollama-ollama-latest.tar" ]; then
        docker load -i "$SCRIPT_DIR/docker_images/ollama-ollama-latest.tar"
        echo -e "${GREEN}✓ Образ загружен из tar${NC}"
    else
        echo -e "${YELLOW}⚠ Tar файл не найден, выполняется docker pull...${NC}"
        docker pull ollama/ollama:latest
    fi
fi

# Очистка предыдущих временных контейнеров
docker rm -f ollama-export 2>/dev/null || true

# Создание временного volume
docker volume create "$TEMP_VOLUME"

# Запуск Ollama для скачивания модели
echo ""
echo "Запуск Ollama и скачивание модели..."
echo "⚠ Это может занять несколько минут..."
docker run -d \
    --name ollama-export \
    -v "$TEMP_VOLUME":/root/.ollama \
    ollama/ollama:latest \
    serve

# Ожидание запуска
sleep 5

# Скачивание модели
echo ""
echo "Скачивание модели $MODEL..."
docker exec ollama-export ollama pull "$MODEL"

# Проверка что модель загружена
echo ""
echo "Проверка загруженной модели..."
docker exec ollama-export ollama list

# Остановка контейнера
echo ""
echo "Остановка временного контейнера..."
docker stop ollama-export
docker rm ollama-export

# Экспорт данных из volume
echo ""
echo "Экспорт модели в $EMBEDDERS_DIR/$MODEL..."
mkdir -p "$EMBEDDERS_DIR/$MODEL"

# Создание архива напрямую из volume (избегаем проблем с правами)
echo ""
echo "Создание архива модели..."
docker run --rm \
    -v "$TEMP_VOLUME":/data \
    -v "$EMBEDDERS_DIR":/export \
    alpine sh -c "tar -czf /export/$MODEL.tar.gz -C /data ."

# Удаление временного volume
docker volume rm "$TEMP_VOLUME"

# Распаковка архива для локального использования
echo ""
echo "Распаковка модели..."
mkdir -p "$EMBEDDERS_DIR/$MODEL"
tar -xzf "$EMBEDDERS_DIR/$MODEL.tar.gz" -C "$EMBEDDERS_DIR/$MODEL"
ARCHIVE_SIZE=$(du -h "$EMBEDDERS_DIR/$MODEL.tar.gz" | cut -f1)
echo -e "${GREEN}✓ Архив создан: embedders/$MODEL.tar.gz ($ARCHIVE_SIZE)${NC}"

echo ""
echo "=============================================="
echo -e "${GREEN}✓ Модель готова для офлайн-использования!${NC}"
echo "=============================================="
echo ""
echo "Структура:"
echo "  embedders/"
echo "    ├── $MODEL/         # Распакованная модель"
echo "    └── $MODEL.tar.gz   # Архив для переноса"
echo ""
echo "Для переноса на другую машину скопируйте:"
echo "  - Папку embedders/ целиком"
echo "  ИЛИ"
echo "  - Архив embedders/$MODEL.tar.gz (распаковать tar -xzf)"
echo ""
echo "Модель будет автоматически загружена при запуске setup-ollama.sh"
echo ""
