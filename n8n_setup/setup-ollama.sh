#!/bin/bash

# Скрипт для загрузки Ollama модели из локальных файлов (OFFLINE)
# Больше не требует интернета!

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL="${OLLAMA_MODEL:-nomic-embed-text}"
EMBEDDERS_DIR="$SCRIPT_DIR/embedders"

echo "=============================================="
echo "  Подготовка Ollama (ОФЛАЙН-РЕЖИМ)"
echo "=============================================="
echo ""
echo "Модель: $MODEL"
echo ""

# Проверка наличия docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker не установлен${NC}"
    exit 1
fi

# Проверка существования volume ollama_data
echo "Проверка volume ollama_data..."
if docker volume ls | grep -q "ollama_data"; then
    echo -e "${GREEN}✓ Volume ollama_data существует${NC}"
    
    # Проверка, есть ли уже модель в volume
    if docker run --rm -v ollama_data:/data alpine test -f "/data/manifests/registry.ollama.ai/library/$MODEL/latest" 2>/dev/null; then
        echo -e "${GREEN}✓ Модель $MODEL уже загружена в volume${NC}"
        echo ""
        echo "=============================================="
        echo -e "${GREEN}✓ Ollama готов к работе!${NC}"
        echo "=============================================="
        exit 0
    fi
else
    echo "Создание volume ollama_data..."
    docker volume create ollama_data
fi

# Проверка наличия локальных файлов модели
echo ""
echo "Проверка локальных файлов модели..."

MODEL_DIR="$EMBEDDERS_DIR/$MODEL"
MODEL_ARCHIVE="$EMBEDDERS_DIR/$MODEL.tar.gz"

if [ -d "$MODEL_DIR" ] && [ "$(ls -A "$MODEL_DIR" 2>/dev/null)" ]; then
    echo -e "${GREEN}✓ Найдена распакованная модель: $MODEL_DIR${NC}"
    SOURCE_DIR="$MODEL_DIR"
    SOURCE_TYPE="directory"
elif [ -f "$MODEL_ARCHIVE" ]; then
    echo -e "${GREEN}✓ Найден архив модели: $MODEL_ARCHIVE${NC}"
    SOURCE_DIR="$MODEL_ARCHIVE"
    SOURCE_TYPE="archive"
else
    echo -e "${RED}✗ Локальные файлы модели не найдены!${NC}"
    echo ""
    echo "Необходимо подготовить модель:"
    echo "  1. На машине с интернетом запустите:"
    echo "     bash export-model.sh"
    echo ""
    echo "  2. Скопируйте папку embedders/ на эту машину"
    echo ""
    echo "  3. Затем повторите: bash setup-ollama.sh"
    echo ""
    echo "Ожидаемая структура:"
    echo "  embedders/"
    echo "    ├── $MODEL/           # Распакованные файлы модели"
    echo "    └── $MODEL.tar.gz     # ИЛИ архив"
    echo ""
    exit 1
fi

# Загрузка Docker образа Ollama
echo ""
echo "Загрузка образа Ollama..."
if ! docker images | grep -q "ollama/ollama"; then
    if [ -f "$SCRIPT_DIR/docker_images/ollama-ollama-latest.tar" ]; then
        docker load -i "$SCRIPT_DIR/docker_images/ollama-ollama-latest.tar"
        echo -e "${GREEN}✓ Образ загружен из tar${NC}"
    else
        echo -e "${RED}✗ Образ Ollama не найден!${NC}"
        echo "Загрузите его: docker pull ollama/ollama:latest"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Образ Ollama уже загружен${NC}"
fi

# Копирование модели в volume
echo ""
echo "Копирование модели в volume ollama_data..."

if [ "$SOURCE_TYPE" = "directory" ]; then
    # Копирование из распакованной директории
    docker run --rm \
        -v "$SOURCE_DIR":/source:ro \
        -v ollama_data:/data \
        alpine sh -c "cp -r /source/* /data/"
elif [ "$SOURCE_TYPE" = "archive" ]; then
    # Распаковка из архива (архив содержит файлы в корне)
    docker run --rm \
        -v "$SOURCE_DIR":/source.tar.gz:ro \
        -v ollama_data:/data \
        alpine sh -c "tar -xzf /source.tar.gz -C /data"
fi

echo -e "${GREEN}✓ Модель скопирована в volume${NC}"

# Проверка
echo ""
echo "Проверка установленной модели..."
docker run --rm \
    -v ollama_data:/root/.ollama \
    ollama/ollama:latest \
    sh -c "ollama list" 2>/dev/null || echo "  (проверка будет доступна после запуска Ollama)"

echo ""
echo "=============================================="
echo -e "${GREEN}✓ Ollama готов к работе (полностью офлайн)!${NC}"
echo "=============================================="
echo ""
echo "Теперь можно запускать сервисы:"
echo "  bash start.sh"
echo ""
