@echo off
chcp 65001 >nul
color 0A
cls

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ============================================================
echo   🚀 PLAKA OKUMA SİSTEMİ - BACKEND BAŞLATILIYOR
echo ============================================================
echo.
echo 📂 Çalışma dizini: %CD%
echo.

REM Check if venv exists
if not exist "venv\Scripts\python.exe" (
    echo ❌ HATA: Virtual environment bulunamadı!
    echo.
    echo 📂 Aranan konum: %CD%\venv\Scripts\python.exe
    echo.
    echo Lütfen önce SETUP_AND_START.bat dosyasını çalıştırın.
    echo.
    pause
    exit /b 1
)

echo ✅ Virtual environment bulundu: venv\Scripts\python.exe
echo.

REM Check if .env exists
if not exist ".env" (
    echo ⚠️  UYARI: .env dosyası bulunamadı!
    echo 📂 Aranan konum: %CD%\.env
    echo.
    echo Varsayılan ayarlarla devam ediliyor...
    echo.
)

REM Read PORT from .env file (default 8001)
set BACKEND_PORT=8001
for /f "tokens=1,2 delims==" %%a in ('findstr /r "^PORT=" .env 2^>nul') do set BACKEND_PORT=%%b

REM Activate virtual environment and start server
echo 📡 Sunucu başlatılıyor...
echo 🌐 Port: %BACKEND_PORT%
echo 📁 Server dosyası: %CD%\server.py
echo.
echo ============================================================
echo   Backend logları aşağıda görünecek:
echo ============================================================
echo.

REM Activate venv and run uvicorn
call "%CD%\venv\Scripts\activate.bat"
uvicorn server:app --host 0.0.0.0 --port %BACKEND_PORT% --reload

echo.
echo ============================================================
echo   🛑 Backend kapatıldı
echo ============================================================
echo.
pause
