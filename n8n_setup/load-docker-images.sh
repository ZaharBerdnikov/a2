#!/bin/bash

# Скрипт для загрузки Docker образов из .tar файлов
# Источник: /media/zahar/Arxiv_256Gb/Zahar/n8n_setup/docker_images

SOURCE_DIR="$(dirname "$0")/docker_images"

# Проверка существования директории
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: Директория $SOURCE_DIR не существует"
    exit 1
fi

# Подсчет найденных .tar файлов
tar_files=($(find "$SOURCE_DIR" -maxdepth 1 -name "*.tar" -type f))
count=${#tar_files[@]}

if [ $count -eq 0 ]; then
    echo "В директории $SOURCE_DIR не найдено .tar файлов"
    exit 0
fi

echo "Найдено $count Docker образов для проверки..."
echo ""

# Получаем список существующих образов
echo "Получение списка существующих Docker образов..."
existing_images=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | sort -u)
if [ $? -ne 0 ]; then
    echo "Предупреждение: Не удалось получить список образов, продолжаем без проверки"
    existing_images=""
fi

# Функция для извлечения тегов из tar-файла
get_image_tags_from_tar() {
    local tar_file="$1"
    local tags=""
    
    # Извлекаем manifest.json из tar-файла и парсим RepoTags
    # manifest.json содержит массив с информацией об образах
    if command -v jq &> /dev/null; then
        tags=$(tar -xf "$tar_file" -O manifest.json 2>/dev/null | jq -r '.[0].RepoTags[]' 2>/dev/null)
    else
        # Fallback без jq - просто загружаем без проверки
        echo ""
        return
    fi
    
    echo "$tags"
}

# Загрузка каждого образа
loaded=0
skipped=0
failed=0

for tar_file in "${tar_files[@]}"; do
    filename=$(basename "$tar_file")
    
    # Пытаемся получить теги из tar-файла
    image_tags=$(get_image_tags_from_tar "$tar_file")
    
    # Проверяем, есть ли уже образ с таким тегом
    skip=false
    if [ -n "$image_tags" ] && [ -n "$existing_images" ]; then
        while IFS= read -r tag; do
            if echo "$existing_images" | grep -q "^${tag}$"; then
                echo "Пропуск: $filename (образ $tag уже существует)"
                ((skipped++))
                skip=true
                break
            fi
        done <<< "$image_tags"
    fi
    
    if [ "$skip" = true ]; then
        echo ""
        continue
    fi
    
    # Если jq не установлен или теги не удалось определить, загружаем без проверки
    if [ -z "$image_tags" ]; then
        echo "Загрузка: $filename (не удалось проверить существование, загружаем)..."
    else
        echo "Загрузка: $filename ..."
    fi
    
    if docker load -i "$tar_file"; then
        echo "✓ Успешно загружен: $filename"
        ((loaded++))
    else
        echo "✗ Ошибка загрузки: $filename"
        ((failed++))
    fi
    echo ""
done

echo "========================================"
echo "Загрузка завершена!"
echo "Успешно загружено: $loaded"
echo "Пропущено (уже существуют): $skipped"
echo "Ошибок: $failed"
echo "========================================"
echo ""
echo "Загруженные MCP образы:"
docker images --format "table {{.Repository}}\t{{.Tag}}" | grep -E "(n8n-mcp|postgres-mcp|playwright-mcp|mcp-docker)" || echo "  (проверьте docker images)"
echo ""
echo "Важно: Убедитесь что образы имеют правильные имена для MCP.yml:"
echo "  - mcp-docker-n8n:latest"
echo "  - mcp-docker-postgres:latest"
echo "  - mcp-docker-playwright:latest"
echo ""
echo "Если имена отличаются, переименуйте:"
echo "  docker tag <старое_имя>:<тег> mcp-docker-n8n:latest"
echo ""
echo "Запустите проверку: bash check-images.sh"
echo ""

if [ $failed -gt 0 ]; then
    exit 1
fi

exit 0
