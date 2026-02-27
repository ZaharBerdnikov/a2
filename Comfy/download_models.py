#!/usr/bin/env python3
"""
Скрипт для автоматической загрузки моделей Stable Diffusion
"""

import os
import sys
import urllib.request
from pathlib import Path

# Предустановленные модели
MODELS = {
    # Stable Diffusion 1.5
    "sd15": {
        "url": "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors",
        "filename": "sd_v1-5-pruned-emaonly.safetensors",
        "dir": "checkpoints"
    },
    # Stable Diffusion XL Base 1.0
    "sdxl_base": {
        "url": "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors",
        "filename": "sd_xl_base_1.0.safetensors",
        "dir": "checkpoints"
    },
    # Stable Diffusion XL Refiner 1.0
    "sdxl_refiner": {
        "url": "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors",
        "filename": "sd_xl_refiner_1.0.safetensors",
        "dir": "checkpoints"
    },
    # SDXL VAE
    "sdxl_vae": {
        "url": "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors",
        "filename": "sdxl_vae.safetensors",
        "dir": "vae"
    },
    # VAE для SD 1.5
    "vae_ft_mse": {
        "url": "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors",
        "filename": "vae-ft-mse-840000-ema-pruned.safetensors",
        "dir": "vae"
    }
}

def download_file(url, dest_path):
    """Скачивает файл с прогрессом"""
    print(f"Скачивание: {url}")
    print(f"В: {dest_path}")
    
    def report_progress(block_num, block_size, total_size):
        downloaded = block_num * block_size
        percent = min(downloaded * 100 / total_size, 100)
        print(f"\rПрогресс: {percent:.1f}%", end='', flush=True)
    
    try:
        urllib.request.urlretrieve(url, dest_path, reporthook=report_progress)
        print("\n✓ Загрузка завершена")
        return True
    except Exception as e:
        print(f"\n✗ Ошибка загрузки: {e}")
        return False

def download_model(model_key):
    """Скачивает модель по ключу"""
    if model_key not in MODELS:
        print(f"Неизвестная модель: {model_key}")
        print(f"Доступные модели: {', '.join(MODELS.keys())}")
        return False
    
    model = MODELS[model_key]
    model_dir = Path(f"/app/models/{model['dir']}")
    model_dir.mkdir(parents=True, exist_ok=True)
    
    dest_path = model_dir / model['filename']
    
    if dest_path.exists():
        print(f"Модель {model_key} уже существует: {dest_path}")
        return True
    
    return download_file(model['url'], dest_path)

def main():
    # Получаем список моделей из переменной окружения
    models_env = os.environ.get('MODELS_TO_DOWNLOAD', '')
    
    if not models_env:
        print("Переменная MODELS_TO_DOWNLOAD не установлена")
        print("Доступные модели:")
        for key in MODELS.keys():
            print(f"  - {key}")
        return
    
    models_to_download = [m.strip() for m in models_env.split(',') if m.strip()]
    
    print(f"Модели для загрузки: {', '.join(models_to_download)}\n")
    
    success_count = 0
    for model_key in models_to_download:
        if download_model(model_key):
            success_count += 1
        print()
    
    print(f"Загружено {success_count}/{len(models_to_download)} моделей")

if __name__ == "__main__":
    main()
