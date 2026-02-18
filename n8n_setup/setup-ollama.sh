#!/bin/bash

# Скрипт для подготовки Ollama volume с моделью
# Выполняется ОДИН РАЗ с интернетом, затем volume можно переносить на другие машины

set -e

echo "=============================================="
echo "  Подготовка Ollama volume с моделью"
echo "=============================================="
echo ""
echo "⚠ Важно: Этот скрипт требует интернет для скачивания модели!"
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODEL="${OLLAMA_MODEL:-nomic-embed-text}"

echo "Модель для скачивания: $MODEL"
echo ""

# Проверка наличия docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker не установлен${NC}"
    exit 1
fi

# Загрузка образа Ollama если не загружен
if ! docker images | grep -q "ollama/ollama"; then
    echo "Загрузка образа Ollama..."
    if [ -f "docker_images/ollama-ollama-latest.tar" ]; then
        docker load -i docker_images/ollama-ollama-latest.tar
        echo -e "${GREEN}✓ Образ загружен из tar${NC}"
    else
        echo -e "${YELLOW}⚠ Tar файл не найден, потребуется docker pull (нужен интернет)${NC}"
        docker pull ollama/ollama:latest
    fi
fi

# Запуск Ollama (сеть не требуется для скачивания модели)
echo ""
echo "Запуск Ollama..."
docker run -d \
    --name ollama-setup \
    -v ollama_data:/root/.ollama \
    -p 11434:11434 \
    ollama/ollama:latest \
    serve

echo "Ожидание запуска Ollama..."
sleep 5

# Скачивание модели
echo ""
echo "Скачивание модели $MODEL..."
echo "⚠ Это может занять несколько минут..."
docker exec ollama-setup ollama pull $MODEL

echo -e "${GREEN}✓ Модель скачана!${NC}"

# Остановка контейнера
echo ""
echo "Остановка временного контейнера..."
docker stop ollama-setup
docker rm ollama-setup

echo ""
echo "=============================================="
echo -e "${GREEN}✓ Ollama volume готов!${NC}"
echo "=============================================="
echo ""
echo "Теперь можно запускать RAG сервисы:"
echo "  docker compose -f RAG.yml up -d"
echo ""
echo "Для переноса на другую машину (офлайн):"
echo "  1. Экспорт volume:"
echo "     docker run --rm -v ollama_data:/data -v \$(pwd):/backup alpine tar czf /backup/ollama_data_backup.tar.gz -C /data ."
echo ""
echo "  2. На новой машине импорт:"
echo "     docker volume create ollama_data"
echo "     docker run --rm -v ollama_data:/data -v \$(pwd):/backup alpine tar xzf /backup/ollama_data_backup.tar.gz -C /data"
echo ""
