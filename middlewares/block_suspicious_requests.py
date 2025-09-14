# middlewares/block_suspicious_requests.py
import re
import logging
from django.http import HttpResponseForbidden

# Логгер только для подозрительных запросов
logger = logging.getLogger("suspicious")

SUSPICIOUS_PATTERNS = [
    re.compile(r'/wp-admin', re.IGNORECASE),
    re.compile(r'/wordpress', re.IGNORECASE),
    re.compile(r'\.env$', re.IGNORECASE),
    re.compile(r'xmlrpc\.php', re.IGNORECASE),
    re.compile(r'wlwmanifest\.xml', re.IGNORECASE),
]

class BlockSuspiciousRequestsMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        path = request.path
        for pattern in SUSPICIOUS_PATTERNS:
            if pattern.search(path):
                # Логируем только подозрительные запросы
                logger.info(f"Suspicious request from {request.META.get('REMOTE_ADDR')}: {path}")
                return HttpResponseForbidden("Forbidden")
        # Обычные запросы пропускаем без логирования
        return self.get_response(request)
