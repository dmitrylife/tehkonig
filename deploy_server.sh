#!/bin/bash
set -e

: '
Скрипт деплоя на сервере
- Обновляет код из Git
- Активирует виртуальное окружение
- Обновляет зависимости
- Применяет миграции
- Собирает статику
- Перезапускает Gunicorn
- Логирует действия
'

# -------------------------------
# Настройки проекта
# -------------------------------
PROJECT_DIR="/home/dmitry/www/tehkonig.ru"
GIT_BRANCH="main"
VENV_DIR="$PROJECT_DIR/.venv"
SERVICE_NAME="tehkonig_site.service"
LOG_FILE="$PROJECT_DIR/logs/deploy_server.log"

mkdir -p "$PROJECT_DIR/logs"

# -------------------------------
# Логирование
# -------------------------------
timestamp() {
    date +"%F %T"
}

log() {
    echo "[$(timestamp)] $*" | tee -a "$LOG_FILE"
}

cd "$PROJECT_DIR"

# -------------------------------
# Обновление кода
# -------------------------------
log "🌐 Обновляем код из Git..."
git fetch origin
git reset --hard origin/$GIT_BRANCH
# Очищаем только неотслеживаемые файлы, исключая важные папки
git clean -fd -e .venv -e logs -e staticfiles -e media -e .git
git pull origin $GIT_BRANCH

# -------------------------------
# Виртуальное окружение
# -------------------------------
if [ ! -d "$VENV_DIR" ]; then
    log "📦 Виртуальное окружение не найдено, создаём..."
    python3 -m venv "$VENV_DIR"
fi

log "⚡ Активируем виртуальное окружение..."
source "$VENV_DIR/bin/activate"

# -------------------------------
# Зависимости
# -------------------------------
log "📦 Обновляем зависимости..."
pip install --upgrade pip
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    pip install -r requirements.txt
else
    log "❌ requirements.txt не найден!"
fi

# -------------------------------
# Миграции и статика
# -------------------------------
mkdir -p staticfiles media

# Временно отключаем exit-on-error для миграций и статики
set +e

log "🗄️ Применяем миграции..."
python manage.py migrate
if [ $? -ne 0 ]; then log "⚠️ Ошибка при миграциях"; fi

log "📁 Собираем статику..."
python manage.py collectstatic --noinput
if [ $? -ne 0 ]; then log "⚠️ Ошибка при сборке статики"; fi

# Включаем exit-on-error обратно
set -e

# -------------------------------
# Перезапуск Gunicorn
# -------------------------------
log "🔁 Перезапускаем Gunicorn..."
sudo systemctl restart $SERVICE_NAME


log "✅ Деплой на сервере завершён!"

