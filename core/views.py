from django.shortcuts import render

# Главное представление (страница старта)
def index(request):
    return render(request, 'core/index.html')

# Обработчики ошибок
def error_403(request, exception):
    return render(request, 'exceptions/403.html', status=403)

def error_404(request, exception):
    return render(request, 'exceptions/404.html', status=404)

def error_500(request):
    return render(request, 'exceptions/500.html', status=500)
