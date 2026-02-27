# Skills Executor API

FastAPI приложение для выполнения Python скриптов (skills) через HTTP API.

## Структура проекта

```
.
├── main.py              # FastAPI приложение
├── requirements.txt     # Зависимости
├── skills/             # Папка со скриптами
│   ├── __init__.py
│   ├── example_skill.py
│   ├── hello_world.py
│   └── calculator.py
└── README.md
```

## Установка

```bash
# Установить зависимости
pip install -r requirements.txt
```

## Запуск приложения

```bash
# Разработка (с автоперезагрузкой)
uvicorn main:app --reload

# Продакшен
uvicorn main:app --host 0.0.0.0 --port 8000
```

## API Endpoints

### POST /execute

Выполняет указанный skill.

**Request:**
```json
{
  "skill_name": "hello_world",
  "params": {
    "name": "User"
  },
  "timeout": 30
}
```

**Response:**
```json
{
  "success": true,
  "result": {
    "greeting": "Hello, User!",
    "additional_params": {},
    "status": "success"
  },
  "error": null
}
```

### GET /skills

Возвращает список доступных skills.

**Response:**
```json
{
  "skills": ["example_skill", "hello_world", "calculator"]
}
```

### GET /

Информация о приложении.

## Как создать новый skill

1. Создайте файл `.py` в папке `skills/`
2. Добавьте функцию `main(**kwargs)`
3. Функция должна возвращать результат (любой JSON-сериализуемый объект)

**Пример skill:**

```python
def main(name="World", **kwargs):
    return {
        "message": f"Hello, {name}!",
        "params": kwargs
    }
```

## Тестирование

### Тест 1: Проверка доступности API
```bash
curl http://localhost:8000/
```

### Тест 2: Список skills
```bash
curl http://localhost:8000/skills
```

### Тест 3: Выполнение hello_world
```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "hello_world", "params": {"name": "FastAPI"}}'
```

### Тест 4: Калькулятор
```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "calculator", "params": {"operation": "multiply", "a": 5, "b": 3}}'
```

### Тест 5: С таймаутом
```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "example_skill", "params": {}, "timeout": 5}'
```

### Тест 6: Движение мыши (pyautogui)
```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "mouse_move", "params": {"x": 500, "y": 300}}'

ВНИМАНИЕ ДЛЯ КОРРЕКТНОЙ РАБОТЫ ТРЕБУЕТСЯ ПАКЕТ TKINTER
```

## Интеграция с n8n

Для использования из n8n (Docker):

1. Убедитесь что FastAPI доступен из контейнера n8n:
   - Если n8n в Docker, используйте `host.docker.internal:8000` (macOS/Windows)
   - Или IP адрес хоста: `192.168.x.x:8000`

2. В n8n добавьте HTTP Request node:
   - Method: POST
   - URL: `http://host.docker.internal:8000/execute`
   - Body: `{"skill_name": "your_skill", "params": {"key": "value"}}`

3. Для Linux Docker используйте сеть:
   ```bash
   docker run --network="host" n8nio/n8n
   ```

## Документация API

После запуска доступна автоматическая документация:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
