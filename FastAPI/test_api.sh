#!/bin/bash
# Тестирование Skills Executor API

echo "=== Тестирование Skills Executor API ==="
echo ""

echo "1. Проверка доступности API:"
curl -s http://localhost:8000/ | python3 -m json.tool
echo ""

echo "2. Список доступных skills:"
curl -s http://localhost:8000/skills | python3 -m json.tool
echo ""

echo "3. Тест hello_world:"
curl -s -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "hello_world", "params": {"name": "FastAPI"}}' | python3 -m json.tool
echo ""

echo "4. Тест calculator (сложение):"
curl -s -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "calculator", "params": {"operation": "add", "a": 10, "b": 20}}' | python3 -m json.tool
echo ""

echo "5. Тест calculator (умножение):"
curl -s -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "calculator", "params": {"operation": "multiply", "a": 7, "b": 8}}' | python3 -m json.tool
echo ""

echo "6. Тест example_skill с параметрами:"
curl -s -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "example_skill", "params": {"name": "Developer", "greeting_type": "Hello"}}' | python3 -m json.tool
echo ""

echo "7. Тест ошибки (skill не найден):"
curl -s -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{"skill_name": "unknown_skill"}'
echo ""
echo ""

echo "=== Тестирование завершено ==="