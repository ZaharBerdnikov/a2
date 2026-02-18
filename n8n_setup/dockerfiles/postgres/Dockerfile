FROM node:20-slim

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория
WORKDIR /app

# Установка postgres MCP сервера глобально
RUN npm install -g @modelcontextprotocol/server-postgres

# Переменная окружения для подключения к БД
# Будет переопределена через docker compose
ENV DATABASE_URL=postgresql://n8n:n8n_password@host.docker.internal:5432/n8n_vectors

# Запуск в режиме ожидания (для docker exec)
CMD ["tail", "-f", "/dev/null"]