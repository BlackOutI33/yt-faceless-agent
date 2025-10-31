# YouTube Faceless/Animation Agent (Top-100, US, 7-day spike)

Этот инструмент находит **100 видео** с YouTube за последние 7 дней по критериям:
- Регион: **US** (поиск и приоритет каналов из США).
- **Faceless / animation**: фильтры по ключевым словам + анти-эвристики против talking head.
- Рост: **просмотры за первую неделю ≥ 10× подписчиков канала** (приближение: берём текущие просмотры для видео ≤ 7 дней).

> ⚠️ Нужен ключ **YouTube Data API v3**. Создайте проект в Google Cloud, включите API и поместите ключ в `.env`.

## Быстрый старт (локально)

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Вставьте API ключ
cp .env.example .env
# отредактируйте .env и вставьте YOUTUBE_API_KEY=...

# Запуск сбора
python scripts/find_top100.py

# Результаты
open results/yt_animation_faceless_us_top100.csv
open results/yt_animation_faceless_us_top100.json
```

## Быстрый старт (Docker)

```bash
# 1) Отредактируйте .env и вставьте YOUTUBE_API_KEY=...
docker compose up --build
# 2) Собор пройдёт автоматически при старте контейнера (можно выключить авто—см. docker-compose.yml)
# 3) API/панель FastAPI будет на http://localhost:8000
```

## Что входит
- `scripts/find_top100.py` — основной сборщик.
- `app/server.py` — мини API на FastAPI, отдаёт CSV/JSON и простую таблицу.
- `config/queries.txt` — список seed-запросов (можете менять).
- `config/settings.yaml` — пороги и фильтры (язык, регион, паттерны).
- `results/` — будет создан и заполнен результатами после запуска.

## Настройки без правки кода
- Меняйте seed-запросы в `config/queries.txt`.
- Редактируйте пороги/шаблоны в `config/settings.yaml`:
  - возраст (7 дней),
  - ключевые слова для анимации,
  - исключающие слова (против talking head),
  - лимит топа (100).

## Ограничения/честность
- YouTube не отдаёт «просмотры за первые 7 дней», поэтому мы фильтруем **строго** видео, которым ≤ 7 дней, и сравниваем **текущие просмотры** с подписчиками канала.
- Каналы со скрытым числом подписчиков исключаются (иначе правило невозможно проверить).
- Региональный приоритет строится по `regionCode=US` в поиске и `brandingSettings.channel.country` у каналов (если доступно).

## Полезно
- Добавьте cron/Prefect, чтобы запускать скрипт ежедневно.
- Для более точного faceless можно потом подключить CLIP-классификацию кадров (см. комментарии в коде).

---

## macOS: быстрый запуск и автозапуск

### Быстрый запуск
```bash
cd yt_faceless_agent
chmod +x macos/install_macos.sh
./macos/install_macos.sh

# Вставьте ключ в .env
open -e .env  # или любой редактор

# Прогон сбора
source .venv/bin/activate
python scripts/find_top100.py

# Локальный UI
uvicorn app.server:app --reload --port 8000
# Откройте http://localhost:8000
```

### Автозапуск раз в день (launchd, 09:00)
1) Переместите проект в домашнюю директорию:
```bash
mv ~/Downloads/yt_faceless_agent ~/yt_faceless_agent
```
2) Дайте права на скрипты:
```bash
chmod +x ~/yt_faceless_agent/macos/run_collector.sh
```
3) Установите LaunchAgent:
```bash
mkdir -p ~/Library/LaunchAgents
cp macos/com.yt.faceless.collector.plist ~/Library/LaunchAgents/
# Отредактируйте путь в ProgramArguments при необходимости, затем:
launchctl load -w ~/Library/LaunchAgents/com.yt.faceless.collector.plist
```
Проверить логи: `~/yt_faceless_agent/logs/collector.log` и `launchd.*.log` в той же папке.

> По умолчанию ключ берётся из `.env`. Если хотите передать ключ через переменную окружения для launchd, раскомментируйте блок `YOUTUBE_API_KEY` в plist и вставьте значение.
