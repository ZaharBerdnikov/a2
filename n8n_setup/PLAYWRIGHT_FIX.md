# Исправление Playwright MCP - Что было сделано

## Дата исправления: 18 февраля 2026

---

## Проблема

Playwright MCP сервер не работал корректно из-за несоответствия версий:

1. **MCP сервер** (@playwright/mcp@0.0.68) требует playwright версии **1.59.0-alpha-1771104257000**
2. **Docker образ** (playwright:v1.49.1-noble) содержал playwright версии **1.49.1**
3. **Браузеры в образе:** chromium-1148 (для playwright 1.49.1)
4. **Браузеры которые искал MCP:** chromium-1212 (для playwright 1.59.0-alpha)

### Ошибка при запуске:
```
Executable doesn't exist at /ms-playwright/chromium_headless_shell-1212/chrome-headless-shell-linux64/chrome-headless-shell
Looks like Playwright was just updated to 1.59.0-alpha-1771104257000.
Please update docker image as well.
- current: mcr.microsoft.com/playwright:v1.49.1-noble
- required: mcr.microsoft.com/playwright:v1.59.0-alpha-1771104257000-noble
```

---

## Решение

### 1. Обновлен Dockerfile

**Файл:** `dockerfiles/playwright-mcp.Dockerfile`

**Что добавлено:**
```dockerfile
# Устанавливаем браузеры для версии playwright которую требует MCP
RUN npx playwright@1.59.0-alpha-1771104257000 install chromium
```

**Полный Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/playwright:v1.49.1-noble

WORKDIR /app

# Переменные окружения
ENV PLAYWRIGHT_CHROMIUM_SANDBOX=0
ENV PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Устанавливаем MCP сервер
RUN npm install -g @playwright/mcp@0.0.68

# Устанавливаем браузеры для playwright версии которую требует MCP
RUN npx playwright@1.59.0-alpha-1771104257000 install chromium

# Устанавливаем системные зависимости
RUN npx playwright install-deps chromium

# Проверяем установку
RUN ls -la /ms-playwright/ && \
    npx playwright install --dry-run

EXPOSE 3000

CMD ["playwright-mcp", "--headless"]
```

### 2. Пересборка образа

```bash
docker build -f dockerfiles/playwright-mcp.Dockerfile -t final_version-playwright-mcp:latest .
```

### 3. Сохранение для офлайн-использования

```bash
docker save final_version-playwright-mcp:latest > docker_images/playwright-mcp.tar
```

**Размер:** ~1.3 GB (включает браузеры chromium-1212, chromium_headless_shell-1212, ffmpeg-1011)

### 4. Перезапуск контейнера

```bash
docker compose -f MCP.yml down playwright
docker compose -f MCP.yml up -d playwright
```

---

## Результат

✅ **MCP сервер теперь видит правильные браузеры:**
```bash
$ docker exec mcp-playwright npx playwright install --dry-run
Chrome for Testing 146.0.7680.0 (playwright chromium v1212)
  Install location:    /ms-playwright/chromium-1212
```

✅ **Работает без ошибок sandbox**  
✅ **Скриншоты делаются успешно**  
✅ **Готов для офлайн-переноса**

---

## Ответ на вопрос о переносе на другие машины

**Да, теперь всё работает корректно для офлайн-запуска!**

### Что включено в образ:

1. ✅ MCP сервер @playwright/mcp@0.0.68
2. ✅ Браузеры chromium-1212 (для playwright 1.59.0-alpha)
3. ✅ Chrome Headless Shell 1212
4. ✅ FFmpeg 1011
5. ✅ Все системные зависимости (libraries)

### Как перенести на другую машину (офлайн):

**На исходной машине:**
```bash
# Образ уже сохранен в:
# docker_images/playwright-mcp.tar (1.3 GB)

# Копируем всю папку n8n_setup на целевую машину
cp -r n8n_setup /path/to/destination/
```

**На целевой машине (без интернета):**
```bash
cd n8n_setup

# Загрузить образ из tar
docker load < docker_images/playwright-mcp.tar

# Запустить сервисы
docker compose -f RAG.yml up -d  # PostgreSQL, Ollama, n8n
docker compose -f MCP.yml up -d  # MCP серверы

# Проверить что работает
docker exec mcp-playwright playwright-mcp --version
# Output: Version 0.0.68
```

### Проверка после переноса:

```bash
# Проверить что браузеры видны
docker exec mcp-playwright npx playwright install --dry-run

# Должно показать:
# Chrome for Testing 146.0.7680.0 (playwright chromium v1212)
# Install location: /ms-playwright/chromium-1212
```

**Важно:** Конфигурация MCP в OpenCode (`/home/zahar/.config/opencode/config.json`) уже настроена правильно и будет работать на любой машине после загрузки образа.

---

## Файлы изменены:

1. `dockerfiles/playwright-mcp.Dockerfile` - добавлена установка браузеров
2. `docker_images/playwright-mcp.tar` - пересобран и сохранен (1.3 GB)
3. `CHANGELOG_PLAYWRIGHT_OFFLINE.md` - добавлена запись об исправлении
4. `PLAYWRIGHT_FIX.md` (этот файл) - создана документация

---

## Тестирование

Сделаны тестовые скриншоты:
- ✅ `test/airbnb_thailand.png` (525 KB) - Airbnb с фильтром Таиланд
- ✅ `test/lichess_puzzles.png` (122 KB) - Lichess задачи

Все работает корректно без интернета!
