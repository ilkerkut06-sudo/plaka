@echo off
chcp 65001 >nul
color 0A
cls

echo ============================================================
echo   🚀 PLAKA OKUMA SİSTEMİ - BACKEND BAŞLATILIYOR
echo ============================================================
echo.

REM Check if venv exists
if not exist "venv\Scripts\python.exe" (
    echo ❌ HATA: Virtual environment bulunamadı!
    echo.
    echo Lütfen önce SETUP_AND_START.bat dosyasını çalıştırın.
    echo.
    pause
    exit /b 1
)

echo ✅ Virtual environment bulundu
echo.

REM Read PORT from .env file (default 8001)
set BACKEND_PORT=8001
for /f "tokens=1,2 delims==" %%a in ('findstr /r "^PORT=" .env 2^>nul') do set BACKEND_PORT=%%b

REM Activate virtual environment and start server
echo 📡 Sunucu başlatılıyor...
echo 🌐 Port: %BACKEND_PORT%
echo.
echo ============================================================
echo   Backend logları aşağıda görünecek:
echo ============================================================
echo.

venv\Scripts\python.exe -m uvicorn server:app --host 0.0.0.0 --port %BACKEND_PORT% --reload

echo.
echo ============================================================
echo   🛑 Backend kapatıldı
echo ============================================================
echo.
pause
