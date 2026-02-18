#!/bin/bash

# Скрипт для проверки и переименования Docker образов
# Проверяет соответствие загруженных образов ожидаемым именам

echo "=== Проверка Docker образов ==="
echo ""

# Ожидаемые образы и их tar-файлы
declare -A expected_images
declare -A tar_files

expected_images["final_version-n8n-mcp"]=":latest"
tar_files["final_version-n8n-mcp"]="n8n-mcp.tar"

expected_images["final_version-postgres-mcp"]=":latest"
tar_files["final_version-postgres-mcp"]="postgres-mcp.tar"

expected_images["mcr.microsoft.com/playwright"]=":v1.49.1-noble"
tar_files["mcr.microsoft.com/playwright"]="playwright-mcp.tar"

# RAG образы
expected_images["ankane/pgvector"]=":latest"
tar_files["ankane/pgvector"]="ankane-pgvector-latest.tar"

expected_images["ollama/ollama"]=":latest"
tar_files["ollama/ollama"]="ollama-ollama-latest.tar"

expected_images["n8nio/n8n"]=":latest"
tar_files["n8nio/n8n"]="n8nio-n8n-latest.tar"

echo "Ожидаемые образы:"
for image in "${!expected_images[@]}"; do
    echo "  - $image${expected_images[$image]} (из ${tar_files[$image]})"
done
echo ""

# Проверка существования образов
echo "Проверка загруженных образов..."
all_found=true

for image in "${!expected_images[@]}"; do
    full_name="$image${expected_images[$image]}"
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${full_name}$"; then
        echo "  ✓ $full_name найден"
    else
        echo "  ✗ $full_name НЕ НАЙДЕН"
        all_found=false
    fi
done

echo ""

if [ "$all_found" = true ]; then
    echo "✓ Все образы найдены! Можно запускать сервисы."
    exit 0
else
    echo "⚠ Некоторые образы не найдены."
    echo ""
    echo "Загруженные образы:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(mcp|playwright)" || echo "  (MCP образы не найдены)"
    echo ""
    echo "Возможные решения:"
    echo "  1. Загрузите образы: bash load-docker-images.sh"
    echo "  2. Если образы загружены под другими именами, переименуйте их:"
    echo ""
    echo "     docker tag <старое_имя>:<тег> mcp-docker-n8n:latest"
    echo "     docker tag <старое_имя>:<тег> mcp-docker-postgres:latest"
    echo "     docker tag <старое_имя>:<тег> mcp-docker-playwright:latest"
    echo ""
    exit 1
fi
