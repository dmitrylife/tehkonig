#!/bin/bash
set -e

# Путь к проекту
PROJECT_DIR="/home/dmitry/www/tehkonig.ru"
# Виртуальное окружение внутри проекта
VENV_DIR="$PROJECT_DIR/.venv"
# Django settings
DJANGO_SETTINGS="rosteplocentr.settings"  # замени на свои

cd $PROJECT_DIR

# Если виртуального окружения нет, создаём
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Создаю виртуальное окружение..."
    python3 -m venv .venv
fi

# Активируем виртуальное окружение
source "$VENV_DIR/bin/activate"

# Rollback на предыдущий коммит
if [[ "$1" == "rollback" ]]; then
    echo "⏪ Откат на предыдущий коммит..."
    git log --oneline -n 2
    PREV_COMMIT=$(git rev-parse HEAD~1)
    git checkout $PREV_COMMIT
    echo "✅ Откат выполнен на коммит $PREV_COMMIT"
else
    echo "🚀 Начинаю деплой..."
    echo "🔄 Обновляю код из Git..."
    git pull origin main
fi

echo "📦 Обновляю зависимости..."
pip install -r requirements.txt

echo "🗄️ Применяю миграции..."
python manage.py migrate --settings=$DJANGO_SETTINGS

echo "📁 Собираю статику..."
python manage.py collectstatic --noinput --settings=$DJANGO_SETTINGS

echo "🔁 Перезапускаю сервисы..."
sudo systemctl restart gunicorn
sudo systemctl restart nginx

echo "✅ Скрипт завершён!"
