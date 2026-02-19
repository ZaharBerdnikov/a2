# Инструкция по развёртыванию n8n MCP сервиса (ПОЛНОСТЬЮ ОФЛАЙН)

## ⚠️ Важно: Полностью локальная работа без интернета

Этот сервис работает **полностью локально без интернета**. Все модели и образы поставляются локально.

## Требования

- Docker и Docker Compose установлены
- Доступ к tar-файлам образов в директории `docker_images/`
- Модель в директории `embedders/` (для полностью офлайн работы)
- Свободные порты: 5432 (PostgreSQL), 5678 (n8n), 11434 (Ollama)

## Быстрый старт (ПОЛНОСТЬЮ ОФЛАЙН)

### 1. Проверьте наличие модели

Для полностью офлайн работы необходима локальная модель в `embedders/`:

```bash
# Проверка
ls -la embedders/nomic-embed-text/
```

Если модели нет, смотрите раздел "Подготовка модели" ниже.

### 2. Автоматический запуск

```bash
# Загрузка образов, подготовка Ollama и запуск всех сервисов
bash start.sh
```

### 3. Настройка API ключа n8n

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

## Подготовка модели (только для первоначальной настройки)

Если у вас нет модели в `embedders/`, выполните на машине с интернетом:

```bash
# Экспорт модели для офлайн-использования
bash export-model.sh
```

Это создаст:
- `embedders/nomic-embed-text/` — распакованная модель
- `embedders/nomic-embed-text.tar.gz` — архив для переноса

Скопируйте папку `embedders/` на целевую машину.

## Перенос на другую машину (офлайн)

### 1. Подготовка на машине с интернетом

```bash
# Выполнить все шаги из "Быстрый старт"
bash export-model.sh
bash load-docker-images.sh

# Остановить сервисы если запущены
docker compose -f RAG.yml down
docker compose -f MCP.yml down
```

### 2. Перенос на офлайн-машину

Скопируйте:
- Папку `n8n_setup/` целиком (включая `embedders/`)

### 3. Запуск на офлайн-машине

```bash
cd n8n_setup

# Запуск (включает загрузку образов, подготовку Ollama и запуск сервисов)
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

### Проблема: модель не найдена

```bash
# Проверка наличия модели в embedders/
ls -la embedders/nomic-embed-text/

# Если модели нет, выполните на машине с интернетом:
bash export-model.sh
```

### Проблема: порт занят

```bash
sudo netstat -tulpn | grep -E "(5432|5678|11434)"
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
| Ollama | ✅ Работает | Локальная модель из embedders/ |
| Postgres MCP | ✅ Работает | Без npx, прямой вызов |
| n8n MCP | ✅ Работает | Без npx, прямой вызов |
| Playwright MCP | ✅ Работает | Браузеры встроены в образ, офлайн |

## Структура проекта

```
n8n_setup/
├── docker_images/          # Docker образы (.tar)
├── dockerfiles/            # Dockerfile для сборки
├── configs/                # Конфигурации MCP агентов
├── embedders/              # Локальные модели (НОВОЕ)
│   └── nomic-embed-text/   # Модель для Ollama
├── RAG.yml                 # Docker Compose для RAG
├── MCP.yml                 # Docker Compose для MCP серверов
├── start.sh                # Основной скрипт запуска
├── setup-ollama.sh         # Подготовка Ollama (офлайн)
├── export-model.sh         # Экспорт модели (требует интернет)
├── load-docker-images.sh   # Загрузка Docker образов
├── check-images.sh         # Проверка образов
└── .env                    # Переменные окружения
```

## Настройка агентов (KiloCode / OpenCode)

### KiloCode

Скопируйте содержимое `configs/kiloconfig` в настройки MCP KiloCode.

### OpenCode

Скопируйте содержимое `configs/opencodeconfig` в настройки MCP OpenCode.

## Доступные сервисы

После запуска:
- **n8n**: http://localhost:5678
- **PostgreSQL**: localhost:5432
- **Ollama**: localhost:11434

## Сборка образов (для разработчиков)

Если нужно обновить образ Playwright MCP с новыми браузерами:

```bash
# Пересборка образа с браузерами
docker build -f dockerfiles/playwright-mcp.Dockerfile -t final_version-playwright-mcp:latest .

# Создание tar-файла для переноса
docker save final_version-playwright-mcp:latest > docker_images/playwright-mcp.tar
```

Браузеры Chromium включены в образ (~300MB) и работают без интернета.
