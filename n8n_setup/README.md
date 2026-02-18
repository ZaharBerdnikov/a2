# Инструкция по развёртыванию n8n MCP сервиса (ОФЛАЙН)

## ⚠️ Важно: Подготовка к офлайн-работе

Этот сервис работает **полностью локально без интернета**, но требует одноразовой подготовки:

1. **Подготовка Ollama** - скачивание модели (требуется интернет 1 раз)
2. **Загрузка Docker образов** - из локальных tar-файлов
3. **Запуск** - полностью офлайн

## Требования

- Docker и Docker Compose установлены
- Доступ к tar-файлам образов в директории `docker_images/`
- Свободные порты: 5432 (PostgreSQL), 5678 (n8n), 11434 (Ollama)
- ⚠️ Для первоначальной подготовки Ollama: доступ в интернет

## Быстрый старт

### Автоматический запуск (всё включено)

```bash
# Проверка и загрузка образов + запуск всех сервисов
bash start.sh
```

### Ручной запуск по шагам

#### Шаг 1: Подготовка Ollama (один раз с интернетом)

```bash
# Скачивание модели nomic-embed-text
bash setup-ollama.sh
```

#### Шаг 2: Загрузка Docker образов (ОБЯЗАТЕЛЬНО!)

⚠️ **Важно**: Docker Compose будет искать образы локально. Если их нет - попытается скачать из интернета.

```bash
# Загрузка всех образов из tar-файлов
bash load-docker-images.sh

# Проверка загруженных образов
bash check-images.sh
```

Ожидаемые образы:
- `final_version-n8n-mcp:latest`
- `final_version-postgres-mcp:latest`
- `mcr.microsoft.com/playwright:v1.49.1-noble`
- `ankane/pgvector:latest`
- `ollama/ollama:latest`
- `n8nio/n8n:latest`

#### Шаг 3: Запуск сервисов

⚠️ **Важно**: Убедитесь что образы загружены (Шаг 2) перед запуском!

```bash
# Запуск RAG (PostgreSQL, Ollama, n8n)
# Сеть rag_network создается автоматически
docker compose -f RAG.yml up -d

# Ожидание готовности PostgreQL
docker compose -f RAG.yml ps

# Запуск MCP серверов
docker compose -f MCP.yml up -d
```

#### Шаг 4: Настройка API ключа n8n

1. Откройте n8n: http://localhost:5678
2. Создайте API ключ в настройках
3. Обновите `.env` файл:

```env
N8N_API_KEY=ваш_новый_api_ключ
```

4. Перезапустите MCP серверы:

```bash
docker compose -f MCP.yml restart
```

## Настройка агентов (KiloCode / OpenCode)

### KiloCode

Скопируйте содержимое `configs/kiloconfig` в настройки MCP KiloCode.

Используемые MCP серверы:
- **postgres** - работа с БД (без npx, напрямую)
- **n8n** - управление workflows (без npx, напрямую)
- **playwright** - автоматизация браузера (✅ работает офлайн, браузеры в образе)

### OpenCode

Скопируйте содержимое `configs/opencodeconfig` в настройки MCP OpenCode.

## Доступные сервисы

После запуска:
- **n8n**: http://localhost:5678
- **PostgreSQL**: localhost:5432
- **Ollama**: localhost:11434

## Перенос на другую машину (офлайн)

### 1. Подготовка на машине с интернетом

```bash
# Выполнить все шаги из "Быстрый старт"
bash setup-ollama.sh
bash load-docker-images.sh
docker compose -f RAG.yml up -d
docker compose -f MCP.yml up -d

# Остановить сервисы
docker compose -f RAG.yml down
docker compose -f MCP.yml down

# Экспортировать volume Ollama
docker run --rm -v ollama_data:/data -v $(pwd):/backup alpine tar czf /backup/ollama_data_backup.tar.gz -C /data .
```

### 2. Перенос на офлайн-машину

Скопируйте:
- Папку `n8n_setup/` целиком
- Файл `ollama_data_backup.tar.gz`

### 3. Запуск на офлайн-машине

```bash
cd n8n_setup

# Импорт Ollama volume (если есть backup)
docker volume create ollama_data
docker run --rm -v ollama_data:/data -v $(pwd):/backup alpine tar xzf /backup/ollama_data_backup.tar.gz -C /data

# Запуск (включает загрузку образов и запуск сервисов)
bash start.sh
```

## Остановка сервисов

```bash
# Остановка всех сервисов
docker compose -f MCP.yml down
docker compose -f RAG.yml down

# Остановка с удалением данных (осторожно!)
docker compose -f RAG.yml down -v
```

## Устранение неполадок

### Проверка логов

```bash
docker compose -f RAG.yml logs -f
docker compose -f MCP.yml logs -f
```

### Проверка образов

```bash
# Должны быть загружены все образы
docker images | grep -E "(final_version|mcr.microsoft|ankane|ollama|n8nio)"
```

### Проблема: образы не найдены

```bash
# Повторная загрузка
bash load-docker-images.sh
bash check-images.sh
```

### Проблема: порт занят

```bash
sudo netstat -tulpn | grep -E "(5432|5678|11434)"
```

### Проблема: Ollama не находит модель

Если Ollama запущен, но модель не найдена:
```bash
# Проверка volume
docker volume ls | grep ollama

# Повторная подготовка (требуется интернет)
bash setup-ollama.sh
```

## Архитектура

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   PostgreSQL    │────▶│   n8n           │────▶│   Ollama        │
│   (pgvector)    │     │   (workflows)   │     │   (embeddings)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                                               ▲
         │                                               │
         ▼                                               │
┌───────────────────────────────────────────────────────────────┐
│                      MCP Servers                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  playwright │  │   postgres   │  │     n8n      │         │
│  │  (offline)  │  │  (offline)   │  │   (offline)  │         │
│  └─────────────┘  └──────────────┘  └──────────────┘         │
└───────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────────┐
│                      AI Agents                                 │
│              (KiloCode / OpenCode)                             │
└───────────────────────────────────────────────────────────────┘
```

## Статус компонентов

| Компонент | Офлайн-статус | Примечание |
|-----------|---------------|------------|
| PostgreSQL | ✅ Работает | Полностью локально |
| n8n | ✅ Работает | Полностью локально |
| Ollama | ✅ Работает | После подготовки модели |
| Postgres MCP | ✅ Работает | Без npx, прямой вызов |
| n8n MCP | ✅ Работает | Без npx, прямой вызов |
| Playwright MCP | ✅ Работает | Браузеры встроены в образ, офлайн |

## Известные ограничения

- **Ollama**: модель скачивается один раз, затем работает офлайн

## Сборка образов (для разработчиков)

Если нужно обновить образ Playwright MCP с новыми браузерами:

```bash
# Пересборка образа с браузерами
docker build -f dockerfiles/playwright-mcp.Dockerfile -t final_version-playwright-mcp:latest .

# Создание tar-файла для переноса
docker save final_version-playwright-mcp:latest > docker_images/playwright-mcp.tar
```

Браузеры Chromium включены в образ (~300MB) и работают без интернета.
