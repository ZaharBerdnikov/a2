#!/bin/bash

# Скрипт для быстрого запуска всего n8n MCP стека
# Выполняет проверку образов, запуск RAG и MCP сервисов

set -e

echo "=============================================="
echo "  Запуск n8n MCP сервиса"
echo "=============================================="
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода ошибки и выхода
error_exit() {
    echo -e "${RED}✗ Ошибка: $1${NC}" >&2
    exit 1
}

# Функция для вывода успеха
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Функция для вывода предупреждения
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    error_exit "Docker не установлен"
fi

if ! docker compose version &> /dev/null; then
    error_exit "Docker Compose не установлен"
fi

success "Docker и Docker Compose найдены"
echo ""

# Загрузка образов из tar файлов (ОБЯЗАТЕЛЬНО перед docker compose)
echo "Загрузка Docker образов из tar файлов..."
bash load-docker-images.sh || error_exit "Не удалось загрузить образы"

# Проверка образов
echo ""
echo "Проверка Docker образов..."
if ! bash check-images.sh; then
    error_exit "Образы не найдены после загрузки"
fi

# Подготовка Ollama (офлайн-режим)
echo ""
echo "Подготовка Ollama с локальной моделью..."
bash setup-ollama.sh || error_exit "Не удалось подготовить Ollama"

echo ""

# Запуск RAG сервисов
echo "Запуск RAG сервисов (PostgreSQL, Ollama, n8n)..."
docker compose -f RAG.yml up -d || error_exit "Не удалось запустить RAG сервисы"
success "RAG сервисы запущены"

echo ""
echo "Ожидание готовности PostgreSQL..."
sleep 5

# Проверка здоровья PostgreSQL
for i in {1..12}; do
    if docker compose -f RAG.yml ps postgres | grep -q "healthy"; then
        success "PostgreSQL готов"
        break
    fi
    echo "  Проверка $i/12..."
    sleep 5
done

if ! docker compose -f RAG.yml ps postgres | grep -q "healthy"; then
    warning "PostgreSQL не стал healthy за отведённое время, но продолжаем..."
fi

echo ""

# Запуск MCP сервисов
echo "Запуск MCP серверов..."
docker compose -f MCP.yml up -d || error_exit "Не удалось запустить MCP серверы"
success "MCP серверы запущены"

echo ""
echo "Проверка статуса контейнеров..."
sleep 2
if docker ps | grep -q "mcp-playwright"; then
    success "Playwright MCP готов (браузеры встроены в образ)"
else
    warning "Playwright MCP контейнер не найден"
fi

echo ""
echo "=============================================="
success "Все сервисы успешно запущены!"
echo "=============================================="
echo ""
echo "Доступные сервисы:"
echo "  • n8n:        http://localhost:5678"
echo "  • PostgreSQL: localhost:5432"
echo "  • Ollama:     localhost:11434"
echo ""
echo "MCP серверы (для агентов):"
echo "  • playwright (mcp-playwright)"
echo "  • postgres   (mcp-postgres)"
echo "  • n8n        (mcp-n8n)"
echo ""
echo "Полезные команды:"
echo "  Просмотр логов RAG:  docker compose -f RAG.yml logs -f"
echo "  Просмотр логов MCP:  docker compose -f MCP.yml logs -f"
echo "  Остановка всех:      docker compose -f RAG.yml down && docker compose -f MCP.yml down"
echo ""
echo "Настройка агентов:"
echo "  Скопируйте configs/kiloconfig в KiloCode"
echo "  Скопируйте configs/opencodeconfig в OpenCode"
echo ""
