#!/bin/bash

# ⚠️ Внимание: все действия удаляют файлы! Используй на dev или после бэкапа.

PROJECT_DIR="$(pwd)"  # корень проекта
MEDIA_DIR="$PROJECT_DIR/media"
STATIC_DIR="$PROJECT_DIR/staticfiles"

echo "1️⃣ Удаляем все __pycache__..."
find "$PROJECT_DIR" -type d -name "__pycache__" -exec rm -rf {} +
echo "__pycache__ удалён ✅"

echo "2️⃣ Удаляем миграции (кроме __init__.py)..."
find "$PROJECT_DIR" -path "*/migrations/*.py" ! -name "__init__.py" -delete
find "$PROJECT_DIR" -path "*/migrations/*.pyc" -delete
echo "Миграции удалены ✅"

echo "3️⃣ Очищаем медиа..."
if [ -d "$MEDIA_DIR" ]; then
    find "$MEDIA_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    echo "Медиа очищено ✅"
else
    echo "Папка media не найдена, пропускаем"
fi

echo "4️⃣ Очищаем статику..."
if [ -d "$STATIC_DIR" ]; then
    rm -rf "$STATIC_DIR"/*
    echo "Статика очищена ✅"
else
    echo "Папка staticfiles не найдена, пропускаем"
fi

echo "5️⃣ Собираем статику заново..."
python manage.py collectstatic --noinput
echo "Статика пересобрана ✅"

echo "✅ Чистка проекта завершена!"
