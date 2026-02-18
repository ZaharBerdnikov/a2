# CHANGELOG - Playwright MCP Офлайн Режим

## Дата: 2024-02-18
## Цель: Настройка Playwright MCP для полной офлайн-работы с браузерами внутри Docker образа

---

## Выполненные изменения

### 1. Конфигурации MCP (Унификация)

**Измененные файлы:**
- `configs/opencodeconfig`
- `/home/zahar/.config/opencode/config.json`

**Изменения:**
- Приведены к единому виду: использование `playwright-mcp` вместо `npx -y @playwright/mcp@latest`
- Добавлены переменные окружения для офлайн-работы

**Причина:** 
- Унификация команд между KiloCode и OpenCode
- Устранение зависимости от npx и интернета
- Браузеры теперь внутри образа

---

### 2. MCP.yml (Docker Compose)

**Измененные параметры:**
- Удален: `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`
- Удален: `PLAYWRIGHT_BROWSERS_PATH=/ms-playwright`
- Удален: volume `playwright_browsers`
- Удалена секция volumes для playwright

**Причина:**
- Браузеры устанавливаются при сборке образа, а не при запуске
- Нет необходимости в отдельном volume
- Упрощает архитектуру и перенос на другие машины

---

### 3. Dockerfile (dockerfiles/playwright-mcp.Dockerfile)

**Изменения:**
- Убрано: `ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`
- Изменено: `ENV PLAYWRIGHT_BROWSERS_PATH=0` (браузеры в ~/.cache/ms-playwright/)
- Оставлено: `RUN npx playwright install chromium && npx playwright install-deps chromium`

**Причина:**
- Браузеры устанавливаются на этапе сборки
- Образ содержит все необходимое для офлайн-работы

---

### 4. start.sh

**Изменения:**
- Убран вызов: `install-playwright-browsers.sh`
- Добавлена проверка запуска Playwright контейнера

**Причина:**
- Браузеры уже в образе, не нужна дополнительная установка

---

### 5. README.md

**Изменения:**
- Обновлен статус Playwright MCP: ⚠️ → ✅ 
- Убрано: "требует доработки"
- Обновлена архитектура (браузеры в образе)
- Добавлен раздел о сборке образа с браузерами

---

### 6. Пересборка образа

**Команды выполнены:**
```bash
docker build -f dockerfiles/playwright-mcp.Dockerfile -t final_version-playwright-mcp:latest .
docker save final_version-playwright-mcp:latest > docker_images/playwright-mcp.tar
```

**Результат:**
- Новый образ содержит Chromium внутри
- Файл для переноса: `docker_images/playwright-mcp.tar`
- Размер образа увеличился (~300MB за счет браузеров)

---

## Результат

### До изменений:
- Браузеры устанавливались при запуске (нужен интернет)
- Конфиги использовали разные команды
- Требовался скрипт install-playwright-browsers.sh
- Volume playwright_browsers мог скрывать браузеры из образа

### После изменений:
- Браузеры включены в Docker образ (офлайн-режим)
- Единые конфиги для всех агентов
- Простой перенос на другие машины (просто скопировать tar)
- Работает без интернета после первичной загрузки образов

---

## Инструкция по переносу на новую машину (офлайн)

1. Скопировать папку `n8n_setup/` целиком
2. На новой машине выполнить: `bash start.sh`
3. Все сервисы запустятся сразу, без необходимости интернета

**Примечание:** Playwright MCP теперь работает полностью автономно!

---

### 7. Исправление критической ошибки версий (2024-02-18)

**Проблема:**
- MCP сервер @0.0.68 требует playwright 1.59.0-alpha
- Базовый образ playwright:v1.49.1-noble содержит playwright 1.49.1
- Происходило несоответствие: MCP искал браузеры chromium-1212, но в образе были chromium-1148
- Ошибка: `Executable doesn't exist at /ms-playwright/chromium_headless_shell-1212/...`

**Решение:**
- Обновлен Dockerfile: добавлена установка браузеров для playwright 1.59.0-alpha
- Команда: `npx playwright@1.59.0-alpha-1771104257000 install chromium`
- Теперь образ содержит оба набора браузеров для совместимости

**Измененные файлы:**
- `dockerfiles/playwright-mcp.Dockerfile` - добавлена установка браузеров для MCP
- `docker_images/playwright-mcp.tar` - пересобран и сохранен

**Результат:**
- MCP сервер теперь видит правильные браузеры (chromium-1212)
- Работает без ошибок sandbox
- Скриншот Airbnb Thailand сохранен в test/airbnb_thailand.png

---

## Проверка работоспособности

Для проверки выполнить тестовое задание с Airbnb:
- Зайти на airbnb.com
- Применить фильтр Таиланд
- Сделать скриншоты жилья
- Сохранить в папку test/
