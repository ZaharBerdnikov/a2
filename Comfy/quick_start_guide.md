# Быстрый старт - Шпаргалка

## 🚀 Настройки для первой генерации

### 1. Загрузи Default workflow
- Нажми **"Load Default"** в правом меню

### 2. Выбери модель
- В ноде **Load Checkpoint** выбери: `sd_xl_base_1.0.safetensors`

### 3. Настрой KSampler (самое важное!)
```
seed: -1                    (случайное)
control_after_generate: randomize
steps: 30                   (20-40 оптимально)
cfg: 7.5                    (7-8 для фото)
sampler_name: dpmpp_2m      (лучший выбор!)
scheduler: karras           (всегда karras!)
denoise: 1.0               (полная генерация)
```

### 4. Размер изображения
```
Empty Latent Image:
  width: 1024
  height: 1024
  batch_size: 1
```

### 5. Промпты

**Positive (что рисовать):**
```
portrait of a beautiful young woman, detailed face, natural skin, 
soft lighting, professional photography, sharp focus, 8k, 
highly detailed, centered composition, looking at camera, 
solo, single person, photorealistic
```

**Negative (что НЕ рисовать):**
```
(worst quality:1.4), (low quality:1.4), (normal quality:1.4), 
lowres, bad anatomy, bad hands, text, error, missing fingers, 
extra digit, fewer digits, cropped, jpeg artifacts, signature, 
watermark, username, blurry, multiple faces, deformed, ugly, 
disfigured, mutation, mutated, extra limbs, fused fingers, 
too many fingers, long neck
```

### 6. Запуск
- Нажми **"Queue Prompt"** (или Ctrl+Enter)
- Жди 15-30 секунд
- Смотри результат в ноде **Save Image**

---

## 🎯 Быстрые настройки под задачи

### Для портрета:
```
Size: 896x1152 (портрет)
Steps: 30-40
CFG: 7-8
Sampler: dpmpp_2m
Scheduler: karras
```

### Для пейзажа:
```
Size: 1152x896 (ландшафт)
Steps: 30-40
CFG: 7-8
Sampler: dpmpp_2m
Scheduler: karras
```

### Для арта/концепт-арта:
```
Size: 1024x1024
Steps: 40-50
CFG: 6-7 (меньше = креативнее)
Sampler: dpmpp_2s_ancestral
Scheduler: karras
```

### Для быстрой генерации:
```
Size: 1024x1024
Steps: 20-25
CFG: 7
Sampler: euler_ancestral
Scheduler: karras
```

---

## ⚡ Горячие клавиши

- **Ctrl+Enter** - Запустить генерацию
- **Ctrl+Z / Ctrl+Y** - Отменить / Повторить
- **Пробел + движение мыши** - Перемещать canvas
- **Колёсико мыши** - Масштаб
- **Двойной клик** - Создать новую ноду
- **Delete** - Удалить выбранную ноду

---

## 🆘 Если что-то пошло не так

**Много лиц/объектов:**
- Добавь в negative: `multiple faces, many, several, group`
- Добавь в positive: `solo, single, one, centered`

**Размытое изображение:**
- Увеличь steps до 30-40
- Добавь в positive: `sharp focus, highly detailed`
- Добавь в negative: `blurry, out of focus`

**Странные цвета:**
- Добавь в positive: `natural colors, realistic lighting`
- CFG: 7-8 (не выше 10)

**Текст/водяные знаки:**
- Добавь в negative: `text, watermark, signature, username`

---

## 🎨 Примеры готовых промптов

### Портрет:
```
Positive:
a portrait of a beautiful young woman with long hair, solo, 
single person, centered, looking at camera, detailed face, 
natural skin texture, soft lighting, professional photography, 
sharp focus, 8k, highly detailed, photorealistic

Negative:
(worst quality:1.4), (low quality:1.4), bad anatomy, bad hands, 
text, error, missing fingers, extra digit, fewer digits, cropped, 
jpeg artifacts, signature, watermark, username, blurry, 
multiple faces, deformed, ugly, disfigured
```

### Пейзаж:
```
Positive:
a beautiful mountain landscape at golden hour, sunset, 
dramatic clouds, majestic peaks, serene lake reflection, 
8k, highly detailed, masterpiece, cinematic composition, 
atmospheric lighting, photorealistic

Negative:
(worst quality:1.4), (low quality:1.4), blurry, oversaturated, 
underexposed, overexposed, cropped, watermark, signature, text, 
low resolution, artifacts, noise, grainy, cartoon, anime
```

### Натюрморт:
```
Positive:
a single red apple on a rustic wooden table, still life photography, 
soft natural lighting from window, shallow depth of field, 
centered composition, photorealistic, 8k, detailed texture

Negative:
(worst quality:1.4), (low quality:1.4), multiple objects, cluttered, 
busy background, blurry, low quality, multiple apples, watermark, 
text, cartoon, anime, painting style
```

### Архитектура:
```
Positive:
modern minimalist living room, interior design, natural lighting, 
large windows, wooden floors, neutral colors, cozy atmosphere, 
architectural photography, 8k, detailed, photorealistic

Negative:
(worst quality:1.4), (low quality:1.4), distorted perspective, 
warped lines, low quality, blurry, oversaturated, cartoon style, 
people, cluttered, messy
```

### Фэнтези:
```
Positive:
elven castle floating in the clouds, fantasy art, majestic towers, 
waterfalls, magical atmosphere, golden sunset, highly detailed, 
8k, masterpiece, trending on artstation, greg rutkowski style

Negative:
(worst quality:1.4), (low quality:1.4), blurry, amateur, deformed, 
ugly, duplicate, watermark, signature, text, cropped, worst quality, 
modern buildings, cars, people
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

## Сэмплеры - подробное описание

### Euler (Эйлер)
- **euler** - Базовый метод Эйлера. Быстрый, простой, но может давать артефакты на малых шагах.
- **euler_ancestral** - Эйлер с добавлением шума. Более креативный, даёт разнообразные результаты.
- **euler_cfg_pp** - Эйлер с улучшенным CFG (Classifier Free Guidance).
- **euler_ancestral_cfg_pp** - Комбинация ancestral + улучшенный CFG.

**Когда использовать:** Для быстрых тестов, когда нужно много итераций.

### Heun
- **heun** - Метод Хойна (предиктор-корректор). Точнее чем Euler, но в 2 раза медленнее.
- **heunpp2** - Улучшенный Heun.
- **exp_heun_2_x0** - Экспериментальный вариант.
- **exp_heun_2_x0_sde** - С SDE (Stochastic Differential Equations).

**Когда использовать:** Когда важна точность, а не скорость.

### DPM (Diffusion Probabilistic Models)
- **dpm_2** - Двухшаговый DPM.
- **dpm_2_ancestral** - DPM-2 с шумом.
- **dpm_fast** - Упрощённый быстрый DPM.
- **dpm_adaptive** - Адаптивный (сам выбирает шаги, непредсказуемое время).

**Когда использовать:** DPM++ лучше, чем базовый DPM.

### DPM++ (Улучшенные DPM) - РЕКОМЕНДУЮТСЯ
- **dpmpp_2s_ancestral** - 2S с шумом, креативный.
- **dpmpp_2s_ancestral_cfg_pp** - С улучшенным CFG.
- **dpmpp_sde** - Как SDE (стохастический).
- **dpmpp_sde_gpu** - Оптимизирован для GPU.
- **dpmpp_2m** ⭐ - САМЫЙ ПОПУЛЯРНЫЙ! Быстрый и качественный.
- **dpmpp_2m_cfg_pp** - С улучшенным CFG.
- **dpmpp_2m_sde** - Комбинация 2M + SDE.
- **dpmpp_2m_sde_gpu** - GPU-оптимизирован.
- **dpmpp_2m_sde_heun** - Комбинация с Heun.
- **dpmpp_2m_sde_heun_gpu** - GPU-версия.
- **dpmpp_3m_sde** - 3M шага (медленнее, но точнее).
- **dpmpp_3m_sde_gpu** - GPU-версия.

**Когда использовать:**
- `dpmpp_2m` - для 90% задач (лучший баланс)
- `dpmpp_2m_sde` - если нужно больше креативности
- `dpmpp_3m_sde` - для максимального качества (медленно)

### DDPM и DDIM
- **ddpm** - Классический DDPM (медленный).
- **ddim** - DDIM (быстрый, хорош на 20-30 шагах).

**Когда использовать:** DDIM для быстрых тестов.

### LCM (Latent Consistency Model)
- **lcm** - ОЧЕНЬ быстрый (4-8 шагов!).

**Когда использовать:** Только с LCM-моделями! Для обычных SDXL не подходит.

### IPNDM
- **ipndm** - Improved Pseudo Numerical Methods.
- **ipndm_v** - Вариант.

**Когда использовать:** Альтернатива DPM++.

### DEIS
- **deis** - Diffusion Exponential Integrator Sampler.

**Когда использовать:** Для быстрой сходимости.

### Мультистеповые
- **res_multistep** - Мультистеповый.
- **res_multistep_cfg_pp** - С улучшенным CFG.
- **res_multistep_ancestral** - С шумом.
- **res_multistep_ancestral_cfg_pp** - Комбинация.

**Когда использовать:** Экспериментальные.

### Градиентные
- **gradient_estimation** - Оценка градиента.
- **gradient_estimation_cfg_pp** - С улучшенным CFG.

**Когда использовать:** Для исследований.

### SDE методы
- **er_sde** - Exponential Runge-Kutta SDE.
- **seeds_2** - SEEDS с 2 шагами.
- **seeds_3** - SEEDS с 3 шагами.
- **sa_solver** - SA Solver.
- **sa_solver_pece** - SA Solver PECE.

**Когда использовать:** Для стохастических эффектов.

### UniPC
- **uni_pc** - Универсальный предиктор-корректор.
- **uni_pc_bh2** - Вариант с другими настройками.

**Когда использовать:** Новый метод, хорош на малых шагах (15-20).

## Итоговая таблица выбора

| Задача | Сэмплер | Шедуллер | Шаги | CFG |
|--------|---------|----------|------|-----|
| Быстрый тест | euler | karras | 20 | 7 |
| Фотореализм | dpmpp_2m | karras | 30 | 7.5 |
| Макс. качество | dpmpp_3m_sde | karras | 50 | 7 |
| Арт/Фэнтези | dpmpp_2s_ancestral | karras | 35 | 6.5 |
| Портреты | dpmpp_2m | karras | 35 | 7.5 |
| Пейзажи | dpmpp_2m | karras | 30 | 7 |
| Мало шагов | uni_pc | karras | 15 | 7 |

## Проверенные комбинации

### Для портрета (фотореалистичного):
```
Sampler: dpmpp_2m
Scheduler: karras
Steps: 35
CFG: 7.5
Size: 896x1152
```

### Для пейзажа:
```
Sampler: dpmpp_2m
Scheduler: karras
Steps: 30
CFG: 7
Size: 1152x896
```

### Для арта:
```
Sampler: dpmpp_2s_ancestral
Scheduler: karras
Steps: 40
CFG: 6.5
Size: 1024x1024
```

### Для быстрого теста:
```
Sampler: euler
Scheduler: karras
Steps: 20
CFG: 7
Size: 1024x1024
```

### Для максимального качества:
```
Sampler: dpmpp_3m_sde
Scheduler: karras
Steps: 50
CFG: 7
Size: 1024x1024
```

## Памятка: CFG Scale

**Меньше (1-6)** → Больше креативности, меньше следование промпту
**Среднее (7-9)** → Баланс (РЕКОМЕНДУЕТСЯ)
**Больше (10-15)** → Строгое следование, но артефакты

**Правило:** Начинай с 7.5, редко выходи за 6-9

## Памятка: Шаги (Steps)

**Мало (10-20)** → Быстро, но может быть шум
**Средне (25-35)** → Оптимально
**Много (40-60)** → Максимум качества, но медленно

**Правило:** 30 шагов для начала, 40-50 для финала

## Памятка: Размер

**SDXL:**
- 1024×1024 - квадрат (универсально)
- 896×1152 - портрет
- 1152×896 - ландшафт
- 1216×832 - широкий
- 832×1216 - высокий

**SD 1.5:**
- 512×512 - стандарт
- 512×768 - портрет
- 768×512 - ландшафт

## Итоговая формула успеха

```
1. Хороший промпт (конкретный, с артиклями)
2. DPM++ 2M + karras
3. 30-40 шагов
4. CFG 7-8
5. Размер под задачу
6. Хороший negative prompt
7. Пробовать разные seed
```

Удачи с генерациями!
