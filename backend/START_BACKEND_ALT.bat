@echo off
chcp 65001 >nul
color 0A
cls

REM Alternative method - Directly call uvicorn.exe
REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ============================================================
echo   🚀 PLAKA OKUMA SİSTEMİ - BACKEND BAŞLATILIYOR (ALT)
echo ============================================================
echo.
echo 📂 Çalışma dizini: %CD%
echo.

REM Check if venv exists
if not exist "venv\Scripts\uvicorn.exe" (
    echo ❌ HATA: uvicorn.exe bulunamadı!
    echo.
    echo 📂 Aranan konum: %CD%\venv\Scripts\uvicorn.exe
    echo.
    echo Lütfen önce SETUP_AND_START.bat dosyasını çalıştırın.
    echo.
    pause
    exit /b 1
)

echo ✅ uvicorn.exe bulundu
echo.

REM Read PORT from .env file (default 8001)
set BACKEND_PORT=8001
for /f "tokens=1,2 delims==" %%a in ('findstr /r "^PORT=" .env 2^>nul') do set BACKEND_PORT=%%b

echo 📡 Sunucu başlatılıyor (Alternatif yöntem)...
echo 🌐 Port: %BACKEND_PORT%
echo.
echo ============================================================
echo   Backend logları aşağıda görünecek:
echo ============================================================
echo.

REM Directly call uvicorn.exe
"%CD%\venv\Scripts\uvicorn.exe" server:app --host 0.0.0.0 --port %BACKEND_PORT% --reload

echo.
echo ============================================================
echo   🛑 Backend kapatıldı
echo ============================================================
echo.
pause
