FROM node:20-slim

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория
WORKDIR /app

# Установка n8n MCP сервера глобально
RUN npm install -g @pagelines/n8n-mcp

# Переменные окружения для подключения к n8n
ENV N8N_API_URL=http://host.docker.internal:5678
ENV N8N_HOST=host.docker.internal
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http

# Keep container running for docker exec
CMD ["tail", "-f", "/dev/null"]

