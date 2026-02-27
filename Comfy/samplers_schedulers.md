# Доступные сэмплеры и шедуллеры в ComfyUI

## Все доступные сэмплеры (SAMPLERS)

### Базовые сэмплеры
- **euler** - Простой и быстрый, хорош для начала
- **euler_ancestral** - Euler с шумом, более креативный
- **euler_cfg_pp** - Euler с улучшенным CFG
- **euler_ancestral_cfg_pp** - Euler Ancestral с улучшенным CFG

### Методы с предиктором-корректором
- **heun** - Более точный чем Euler, но медленнее
- **heunpp2** - Улучшенный Heun
- **exp_heun_2_x0** - Экспериментальный Heun
- **exp_heun_2_x0_sde** - Heun с SDE

### Методы DPM (Diffusion Probabilistic Models)
- **dpm_2** - Двухшаговый DPM
- **dpm_2_ancestral** - DPM-2 с шумом
- **dpm_fast** - Быстрый DPM
- **dpm_adaptive** - Адаптивный DPM (меняет шаги)
- **dpmpp_2s_ancestral** - DPM++ 2S с шумом
- **dpmpp_sde** - DPM++ как SDE
- **dpmpp_sde_gpu** - Оптимизирован для GPU
- **dpmpp_2m** - DPM++ 2M (очень популярный)
- **dpmpp_2m_sde** - DPM++ 2M с SDE
- **dpmpp_2m_sde_gpu** - Оптимизирован для GPU
- **dpmpp_3m_sde** - DPM++ 3M с SDE
- **dpmpp_3m_sde_gpu** - Оптимизирован для GPU

### Другие методы
- **lms** - Linear Multistep
- **ddpm** - Denoising Diffusion Probabilistic Models
- **ddim** - Denoising Diffusion Implicit Models (быстрый)
- **lcm** - Latent Consistency Model (очень быстрый)
- **uni_pc** - UniPC (новый, хорош на малых шагах)
- **uni_pc_bh2** - UniPC с другой настройкой
- **ipndm** - Improved Pseudo Numerical Methods
- **ipndm_v** - Вариант IPNDM
- **deis** - Diffusion Exponential Integrator Sampler

### Мультистеповые методы с CFG++
- **res_multistep** - Мультистеповый
- **res_multistep_cfg_pp** - С улучшенным CFG
- **res_multistep_ancestral** - С шумом
- **gradient_estimation** - Оценка градиента
- **gradient_estimation_cfg_pp** - С улучшенным CFG

### SDE методы
- **er_sde** - Exponential Runge-Kutta SDE
- **seeds_2** - SEEDS с 2 шагами
- **seeds_3** - SEEDS с 3 шагами
- **sa_solver** - SA Solver
- **sa_solver_pece** - SA Solver PECE

## Все доступные шедуллеры (SCHEDULERS)

- **simple** - Простой линейный
- **normal** - Обычный (линейный) планировщик шума
- **karras** - Рекомендуется! Лучшее качество на меньших шагах
- **exponential** - Экспоненциальное уменьшение шума
- **sgm_uniform** - Равномерный для SGM моделей
- **ddim_uniform** - Равномерный для DDIM
- **beta** - Бета-распределение
- **linear_quadratic** - Линейно-квадратичный
- **kl_optimal** - KL-оптимальный

## Рекомендации по выбору

### Для фотореализма (портреты, фото):
- **Сэмплер:** `dpmpp_2m` или `dpmpp_2m_sde`
- **Шедуллер:** `karras`
- **Шаги:** 25-40
- **CFG:** 7-8

### Для быстрой генерации:
- **Сэмплер:** `euler` или `euler_ancestral`
- **Шедуллер:** `karras` или `simple`
- **Шаги:** 15-25

### Для арта/концепт-арта:
- **Сэмплер:** `dpmpp_2s_ancestral` или `dpmpp_sde`
- **Шедуллер:** `karras` или `normal`
- **Шаги:** 30-50

### Для максимального качества:
- **Сэмплер:** `dpmpp_3m_sde` или `uni_pc`
- **Шедуллер:** `karras`
- **Шаги:** 40-60

### Для экономии времени (LCM модели):
- **Сэмплер:** `lcm`
- **Шедуллер:** `simple`
- **Шаги:** 4-8

## Топ-5 комбинаций для начала:

1. **Универсальная:** `dpmpp_2m` + `karras` (30 шагов)
2. **Быстрая:** `euler_ancestral` + `karras` (20 шагов)
3. **Качественная:** `dpmpp_2m_sde` + `karras` (40 шагов)
4. **Креативная:** `dpmpp_sde` + `normal` (35 шагов)
5. **Очень быстрая:** `lcm` + `simple` (8 шагов, только для LCM моделей)

## Важно:
- Всегда используй `karras` шедуллер для лучшего качества
- `dpmpp_2m` - самый популярный выбор
- `euler` - лучший для начала и тестов
- `uni_pc` - новый, хорош на малых шагах (15-20)
