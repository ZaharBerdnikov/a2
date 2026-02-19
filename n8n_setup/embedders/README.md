# Локальные модели для Ollama (OFFLINE)

Эта папка содержит локальные модели для полностью офлайн работы.

## Структура

```
embedders/
├── nomic-embed-text/           # Распакованная модель
│   ├── blobs/                  # Бинарные файлы модели
│   └── manifests/              # Манифесты Ollama
└── nomic-embed-text.tar.gz     # Архив модели (для переноса)
```

## Подготовка модели (на машине с интернетом)

```bash
bash export-model.sh
```

Это создаст папку `nomic-embed-text/` с моделью.

## Перенос на офлайн-машину

Скопируйте всю папку `embedders/` на целевую машину:

```bash
# На машине с интернетом
tar -czf embedders.tar.gz embedders/
scp embedders.tar.gz user@offline-machine:/path/to/n8n_setup/

# На офлайн-машине
cd /path/to/n8n_setup/
tar -xzf embedders.tar.gz
bash start.sh
```

## Примечание

- Не коммитьте модели в git (они очень большие)
- Модель `nomic-embed-text` занимает ~250MB
