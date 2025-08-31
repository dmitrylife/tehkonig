# generate_file_structure.py
import os
from pathlib import Path
import logging

# Настройка логирования
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

def collect_files_content(root_dir: str, exclude_dirs: list, exclude_extensions: list, output_file: str):
    """
    Собирает список файлов и их содержимое в директории, исключая указанные директории и расширения.
    Записывает результат в текстовый файл.
    """
    try:
        root_path = Path(root_dir)
        if not root_path.exists():
            logger.error(f"Директория {root_dir} не существует")
            return

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"Структура и содержимое файлов в {root_dir}\n")
            f.write("=" * 50 + "\n\n")

            for item in sorted(root_path.rglob("*")):
                # Пропускаем директории внутри exclude_dirs
                if any(excluded in item.parts for excluded in exclude_dirs):
                    logger.debug(f"Пропущен элемент (внутри исключенной директории): {item}")
                    continue

                # Пропускаем файлы с исключёнными расширениями
                if item.is_file() and item.suffix in exclude_extensions:
                    logger.debug(f"Пропущен файл по расширению: {item}")
                    continue

                if item.is_file():
                    # Записываем путь файла относительно root_dir
                    relative_path = item.relative_to(root_path)
                    f.write(f"Файл: {relative_path}\n")
                    f.write("-" * 50 + "\n")

                    try:
                        with open(item, "r", encoding="utf-8") as file_content:
                            content = file_content.read()
                            f.write(content + "\n")
                    except UnicodeDecodeError:
                        f.write("⚠️ Не удалось прочитать файл (не текстовый формат)\n")
                        logger.warning(f"Не удалось прочитать {item}: не текстовый формат")
                    except Exception as e:
                        f.write(f"⚠️ Ошибка при чтении файла: {str(e)}\n")
                        logger.error(f"Ошибка при чтении {item}: {str(e)}")

                    f.write("\n" + "=" * 50 + "\n\n")

        logger.info(f"Структура и содержимое файлов записаны в {output_file}")

    except Exception as e:
        logger.error(f"Ошибка при обработке директории {root_dir}: {str(e)}", exc_info=True)

if __name__ == "__main__":
    # Параметры
    root_directory = "install_requests"  # Директория приложения
    exclude_dirs = ["__pycache__", ".git", "venv", "rosteplocentr_venv", "migrations"]
    exclude_extensions = [".pyc"]
    output_file = "file_structure.txt"  # Выходной файл

    # Запуск
    collect_files_content(root_directory, exclude_dirs, exclude_extensions, output_file)
