FROM mcr.microsoft.com/playwright:v1.49.1-noble

# Установка Node.js зависимостей для MCP
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

# Порт для MCP сервера
EXPOSE 3000

# Команда по умолчанию
CMD ["playwright-mcp", "--headless"]
