#!/bin/bash

set -e

echo "========================================"
echo "ComfyUI Docker - Setup Script"
echo "========================================"
echo ""

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен!"
    echo "Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose не установлен!"
    echo "Установите Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker и Docker Compose найдены"

# Проверяем NVIDIA Container Toolkit
echo ""
echo "Проверка NVIDIA Container Toolkit..."
if docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "✅ GPU доступна в Docker"
else
    echo "⚠️  GPU не доступна в Docker"
    echo "Установите NVIDIA Container Toolkit:"
    echo "  https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    echo ""
    read -p "Продолжить без GPU? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Создаем .env если не существует
if [ ! -f .env ]; then
    echo ""
    echo "Создание .env файла..."
    cp .env.example .env
    echo "✅ Создан .env (отредактируйте при необходимости)"
else
    echo "✅ .env уже существует"
fi

# Создаем папки
echo ""
echo "Создание необходимых папок..."
mkdir -p models/{checkpoints,loras,controlnet,vae,embeddings,clip,unet,clip_vision}
mkdir -p input output
echo "✅ Папки созданы"

# Сборка и запуск
echo ""
echo "========================================"
echo "Сборка Docker образа..."
echo "========================================"
docker compose build

echo ""
echo "========================================"
echo "Запуск ComfyUI..."
echo "========================================"
docker compose up -d

echo ""
echo "========================================"
echo "✅ ComfyUI запущен!"
echo "========================================"
echo ""
echo "Доступен по адресу: http://localhost:$(grep COMFYUI_PORT .env | cut -d '=' -f2 | tr -d ' ')"
echo ""
echo "Команды:"
echo "  docker compose logs -f    # Просмотр логов"
echo "  docker compose down       # Остановка"
echo "  docker compose restart    # Перезапуск"
echo ""
