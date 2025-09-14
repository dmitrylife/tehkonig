import os

# Определяем имя текущего хоста
HOSTNAME = os.uname().nodename

# Список локальных машин
LOCAL_HOSTS = ['klimbian', 'klimbook', 'rsk']

# Определяем окружение:
# 1. Если переменная окружения DJANGO_ENV задана — используем её
# 2. Если запускаем через --settings=config.settings.dev — определим dev
# 3. Иначе fallback на prod
env_from_settings = os.environ.get('DJANGO_SETTINGS_MODULE', '')
if 'dev' in env_from_settings:
    ENVIRONMENT = 'dev'
elif HOSTNAME in LOCAL_HOSTS:
    ENVIRONMENT = 'dev'
else:
    ENVIRONMENT = os.environ.get('DJANGO_ENV', 'prod')

# Подключаем соответствующие настройки
if ENVIRONMENT == 'dev':
    from .dev import *
else:
    from .prod import *

print(f"⚙️ Django Environment: {ENVIRONMENT} (HOSTNAME={HOSTNAME})")
