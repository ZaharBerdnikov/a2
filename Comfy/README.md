# ComfyUI Docker

ComfyUI с Stable Diffusion в Docker контейнере с поддержкой GPU (NVIDIA).

## Требования

- **Docker** и **Docker Compose**
- **NVIDIA GPU** (рекомендуется 8GB+ VRAM)
- **NVIDIA Container Toolkit** (для доступа к GPU из контейнера)

## Быстрый старт

### 1. Клонируйте репозиторий

```bash
git clone <your-repo-url>
cd comfyui-docker
```

### 2. Настройте переменные окружения

```bash
cp .env.example .env
# Отредактируйте .env под ваши нужды
```

### 3. Соберите и запустите

```bash
# Сборка образа и запуск с загрузкой моделей
docker compose up -d

# Или без автоматической загрузки моделей
docker compose up -d
```

### 4. Откройте в браузере

- **ComfyUI**: http://localhost:8188
- Интерфейс загрузится автоматически

## Доступные модели

Модели можно скачать автоматически или вручную.

### Автоматическая загрузка

Укажите в `.env`:

```bash
MODELS_TO_DOWNLOAD=sdxl_base,sdxl_vae
```

Доступные модели:
- `sd15` - Stable Diffusion 1.5 (4.27 GB)
- `sdxl_base` - SDXL Base 1.0 (6.94 GB)
- `sdxl_refiner` - SDXL Refiner 1.0 (6.08 GB)
- `sdxl_vae` - SDXL VAE (335 MB)
- `vae_ft_mse` - VAE fine-tuned MSE (335 MB)

### Ручная загрузка моделей

Если не хотите качать через Docker, скачайте вручную в папку `models/checkpoints/`:

**Stable Diffusion 1.5:**
- Официальный: https://huggingface.co/runwayml/stable-diffusion-v1-5
- Прямая ссылка: https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

**Stable Diffusion XL (рекомендуется):**
- SDXL Base 1.0: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
- Прямая ссылка: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

**Другие популярные модели:**
- Realistic Vision: https://civitai.com/models/4201/realistic-vision-v60-b1
- DreamShaper: https://civitai.com/models/4384/dreamshaper
- EpicRealism: https://civitai.com/models/25694/epicrealism

### Другие источники моделей

- **HuggingFace**: https://huggingface.co/models (фильтр: stable-diffusion)
- **CivitAI**: https://civitai.com (нужна регистрация для некоторых моделей)
- **Tensor.art**: https://tensor.art

## Структура папок

```
.
├── models/                 # Модели (сохраняются между запусками)
│   ├── checkpoints/       # Основные модели SD
│   ├── loras/            # LoRA адаптеры
│   ├── controlnet/       # ControlNet модели
│   ├── vae/              # VAE модели
│   ├── embeddings/       # Textual Inversion
│   ├── clip/             # CLIP модели
│   ├── unet/             # UNet модели
│   └── clip_vision/      # CLIP Vision модели
├── input/                 # Входные изображения
├── output/                # Сгенерированные изображения
├── Dockerfile            # Описание образа
├── docker-compose.yml    # Конфигурация запуска (для docker compose)
└── .env                  # Локальные настройки
```

## Команды управления

```bash
# Запуск
docker compose up -d

# Остановка
docker compose down

# Перезапуск
docker compose restart

# Просмотр логов
docker compose logs -f

# Пересборка после изменений
docker compose up -d --build

# Выполнить команду внутри контейнера
docker compose exec comfyui bash

# Остановка и удаление контейнера + volumes
docker compose down -v
```

## Установка NVIDIA Container Toolkit

### Ubuntu/Debian

```bash
# Добавление репозитория
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Установка
sudo apt-get update
sudo apt-get install -y nvidia-docker2

# Перезапуск Docker
sudo systemctl restart docker
```

### Проверка работы GPU

```bash
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

Если видите информацию о GPU — всё работает!

## Решение проблем

### "Cannot connect to the Docker daemon"

```bash
sudo usermod -aG docker $USER
# Перелогиньтесь или:
newgrp docker
```

### GPU не обнаруживается в контейнере

1. Проверьте установку NVIDIA Container Toolkit
2. Проверьте драйверы: `nvidia-smi`
3. Перезапустите Docker: `sudo systemctl restart docker`

### Не хватает памяти VRAM

- Используйте модели SD 1.5 вместо SDXL
- Включите --lowvram или --normalvram в `.env`:
  ```bash
  COMFYUI_EXTRA_ARGS=--lowvram
  ```

### Модели не загружаются автоматически

Проверьте переменную в `.env`:
```bash
MODELS_TO_DOWNLOAD=sdxl_base,sdxl_vae
```

Или скачайте вручную в `models/checkpoints/`.

## Первое использование ComfyUI

1. Откройте http://localhost:8188
2. Нажмите **"Load Default"** для базового workflow
3. Выберите модель в ноде **Load Checkpoint**
4. Введите промпт в ноде **CLIP Text Encode (Prompt)**
5. Нажмите **"Queue Prompt"**

### Полезные горячие клавиши

- **Ctrl + Enter** — Запустить генерацию
- **Ctrl + S** — Сохранить workflow
- **Ctrl + O** — Загрузить workflow
- **H** — Показать/скрыть помощь
- **Double click** — Создать ноду

## Дополнительная документация

- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [ComfyUI Wiki](https://github.com/comfyanonymous/ComfyUI/wiki)
- [ComfyUI Examples](https://comfyanonymous.github.io/ComfyUI_examples/)

## Лицензия

MIT License - см. файл LICENSE
