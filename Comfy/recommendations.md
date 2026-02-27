# ComfyUI - Рекомендации по генерации изображений

## Примеры качественных промптов

### 1. Портрет (фотореалистичный)
**Positive:**
```
portrait of a young woman, detailed face, natural skin texture, 
soft lighting, professional photography, sharp focus, 
8k uhd, dslr, film grain, bokeh background, centered composition
```

**Negative:**
```
(worst quality:1.4), (low quality:1.4), (normal quality:1.4), 
lowres, bad anatomy, bad hands, text, error, missing fingers, 
extra digit, fewer digits, cropped, jpeg artifacts, signature, 
watermark, username, blurry, multiple faces, deformed, ugly
```

### 2. Пейзаж
**Positive:**
```
beautiful mountain landscape at sunset, golden hour, dramatic clouds, 
majestic peaks, serene lake reflection, 8k, highly detailed, 
masterpiece, cinematic composition, atmospheric lighting
```

**Negative:**
```
(worst quality:1.4), (low quality:1.4), blurry, oversaturated, 
underexposed, overexposed, cropped, watermark, signature, text, 
low resolution, artifacts, noise, grainy
```

### 3. Натюрморт
**Positive:**
```
a single red apple on a wooden table, still life photography, 
soft natural lighting from window, shallow depth of field, 
centered composition, photorealistic, 8k, detailed texture
```

**Negative:**
```
multiple objects, cluttered, busy background, blurry, low quality, 
multiple apples, watermark, text, cartoon, anime, painting style
```

### 4. Архитектура/Интерьер
**Positive:**
```
modern minimalist living room, interior design, natural lighting, 
large windows, wooden floors, neutral colors, cozy atmosphere, 
architectural photography, 8k, detailed, photorealistic
```

**Negative:**
```
distorted perspective, warped lines, low quality, blurry, 
oversaturated, cartoon style, people, cluttered, messy
```

### 5. Фэнтези/Концепт-арт
**Positive:**
```
elven castle floating in the clouds, fantasy art, majestic towers, 
waterfalls, magical atmosphere, golden sunset, highly detailed, 
8k, masterpiece, trending on artstation, greg rutkowski style
```

**Negative:**
```
low quality, blurry, amateur, deformed, ugly, duplicate, 
watermark, signature, text, cropped, worst quality
```

## Как улучшить качество изображения

### 1. Увеличьте количество шагов (Steps)
- **20-25 шагов** - быстро, но может быть шумно
- **30-40 шагов** - оптимально для большинства случаев
- **50+ шагов** - максимальное качество, но медленно

### 2. Правильный размер для модели
**Для SDXL:**
- 1024×1024 (квадрат)
- 896×1152 (портрет)
- 1152×896 (ландшафт)
- 1216×832 или 832×1216

**Для SD 1.5:**
- 512×512 (стандарт)
- 512×768 (портрет)
- 768×512 (ландшафт)

### 3. Добавьте ключевые слова качества
```
masterpiece, best quality, highly detailed, 8k, sharp focus, 
professional photography, photorealistic, intricate details
```

### 4. Используйте VAE
В ноде **Load Checkpoint** можно выбрать отдельный VAE:
- `sdxl_vae.safetensors` - для SDXL (уже скачан)
- `vae-ft-mse-840000-ema-pruned.safetensors` - для SD 1.5

### 5. Рабочий процесс для лучшего результата
```
1. Генерируйте с batch_size=4 (4 варианта сразу)
2. Выбирайте лучший
3. Увеличивайте шаги до 40-50
4. Меняйте seed для похожих вариантов
```

## Сэмплеры (Samplers) - что выбрать

### Для фотореализма:

**Euler a** (Euler Ancestral)
- ✅ Быстрый, хорошие результаты
- ✅ Хорош для портретов
- ⚡ Steps: 20-30

**DPM++ 2M Karras**
- ✅ Очень качественный, чёткий
- ✅ Лучший для фотореализма
- ⚡ Steps: 25-40

**DPM++ SDE Karras**
- ✅ Максимально качественный
- ❌ Медленнее
- ⚡ Steps: 30-50

### Для арта/концепт-арта:

**DPM++ 2S a Karras**
- ✅ Креативный, артистичный
- ✅ Хорош для фэнтези
- ⚡ Steps: 25-35

**Euler**
- ✅ Простой, предсказуемый
- ✅ Хорош для стилизации
- ⚡ Steps: 20-30

**UniPC**
- ✅ Новый, быстрый
- ✅ Хорош на низких шагах
- ⚡ Steps: 15-25

### Рекомендация:
- **Начинай с:** `DPM++ 2M Karras`
- **Для максимума качества:** `DPM++ SDE Karras` с 40+ шагами

## Schedulers (Планировщики)

**normal** - стандартный, линейный шум
**karras** - рекомендуется, лучшее качество на меньших шагах
**exponential** - быстрый, агрессивное удаление шума
**simple** - простой, для тестов
**sgm_uniform** - для Stable Diffusion 2.x

### Рекомендация:
- **Всегда используй `karras`** - даёт лучшее качество

## CFG Scale (Classifier Free Guidance)

**Что это:** баланс между следованием промпту и креативностью модели

### Значения:

**CFG 1-3** - ОЧЕНЬ креативно
- Модель игнорирует промпт
- Результаты случайные
- ❌ Не рекомендуется

**CFG 4-6** - Креативно
- Модель следует промпту слабо
- Больше художественной свободы
- ✅ Для арта, концепт-арта

**CFG 7-9** - Баланс (РЕКОМЕНДУЕТСЯ)
- Хорошее следование промпту
- Приемлемая креативность
- ✅ Оптимально для большинства задач

**CFG 10-15** - Точное следование
- Модель строго следует промпту
- Меньше креативности
- ⚠️ Может быть перенасыщенность

**CFG 15+** - Жёсткое следование
- Модель зацикливается на промпте
- ❌ Часто портит изображение
- ❌ Артефакты, перенасыщенность

### Рекомендации по CFG:

| Тип задачи | CFG | Пояснение |
|-----------|-----|-----------|
| Фотореализм | 7-8 | Натуральные цвета |
| Портреты | 7-9 | Чёткие черты лица |
| Арт/Фэнтези | 6-8 | Больше креативности |
| Точные объекты | 8-9 | Строгое следование |
| Стилизация | 5-7 | Художественный эффект |

## Частые проблемы и решения

### Проблема: "Мыльное"/размытое изображение
**Решение:**
- Увеличь steps до 30-40
- Используй DPM++ 2M Karras
- Добавь в negative: `blurry, out of focus`
- Добавь в positive: `sharp focus, highly detailed`

### Проблема: Двойные лица/артефакты
**Решение:**
- Добавь в negative: `multiple faces, deformed, ugly, bad anatomy`
- Используй `solo, single person` в positive
- CFG: 7-8

### Проблема: Слишком много объектов
**Решение:**
- Укажи количество: `a single`, `one`, `solo`
- Добавь в negative: `multiple objects, many, several`
- CFG: 8-9

### Проблема: Неестественные цвета
**Решение:**
- Добавь: `natural colors, realistic lighting`
- CFG: 7-8
- Используй VAE для своей модели

### Проблема: Текст/водяные знаки
**Решение:**
- Добавь в negative: `text, watermark, signature, username`
- CFG: 8-9
- Увеличь steps

## Идеальные настройки для старта

```
Checkpoint: sd_xl_base_1.0.safetensors
Size: 1024x1024
Steps: 30
Sampler: DPM++ 2M Karras
Scheduler: karras
CFG: 7.5
Batch size: 4
```

## Полезные трюки

### 1. Усиление важности слов
```
(важное слово:1.3) - усилить в 1.3 раза
(слово:0.8) - ослабить
```

Пример:
```
a (beautiful:1.3) woman, (detailed:1.2) face
```

### 2. Смешивание стилей
```
[стиль1:стиль2:0.5] - переключение на половине шагов
```

### 3. Постепенное появление
```
[object:0.3] - объект появляется после 30% шагов
```

### 4. Использование весов в negative
```
(deformed:1.5), (ugly:1.3), (bad anatomy:1.4)
```

## Проверочный промпт для теста

Попробуй этот - он должен дать хороший результат:

**Positive:**
```
portrait of a beautiful young woman, detailed face, natural skin, 
soft lighting, professional photography, sharp focus, 8k, 
highly detailed, centered composition, looking at camera, 
solo, single person, photorealistic
```

**Negative:**
```
(worst quality:1.4), (low quality:1.4), (normal quality:1.4), 
lowres, bad anatomy, bad hands, text, error, missing fingers, 
extra digit, fewer digits, cropped, jpeg artifacts, signature, 
watermark, username, blurry, multiple faces, deformed, ugly, 
disfigured, mutation, mutated, extra limbs, fused fingers, 
too many fingers, long neck
```

**Настройки:**
- Steps: 30
- Sampler: DPM++ 2M Karras
- Scheduler: karras
- CFG: 7.5
- Size: 1024x1024

---

## Быстрый старт

1. Открой ComfyUI
2. Нажми "Load Default"
3. Выбери checkpoint: `sd_xl_base_1.0`
4. Вставь промпт сверху
5. Нажми Queue Prompt (Ctrl+Enter)
6. Жди 15-30 секунд
7. Готово!

Удачи с генерациями!
