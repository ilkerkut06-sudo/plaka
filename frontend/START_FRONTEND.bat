@echo off
chcp 65001 >nul
color 0B
cls

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ============================================================
echo   🌐 PLAKA OKUMA SİSTEMİ - FRONTEND BAŞLATILIYOR
echo ============================================================
echo.
echo 📂 Çalışma dizini: %CD%
echo.

REM Check if node_modules exists
if not exist "node_modules" (
    echo ❌ HATA: node_modules klasörü bulunamadı!
    echo.
    echo 📂 Aranan konum: %CD%\node_modules
    echo.
    echo Lütfen önce SETUP_AND_START.bat dosyasını çalıştırın.
    echo.
    pause
    exit /b 1
)

echo ✅ node_modules bulundu: node_modules\
echo.

REM Check if .env exists
if not exist ".env" (
    echo ⚠️  UYARI: .env dosyası bulunamadı!
    echo 📂 Aranan konum: %CD%\.env
    echo.
    echo Varsayılan ayarlarla devam ediliyor...
    echo.
)

REM Check if npm is available
where npm >nul 2>&1
if errorlevel 1 (
    echo ❌ HATA: npm komutu bulunamadı!
    echo.
    echo Node.js kurulu olduğundan emin olun.
    echo İndirmek için: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo 🚀 React uygulaması başlatılıyor...
echo.
echo ============================================================
echo   Frontend logları aşağıda görünecek:
echo ============================================================
echo.

npm start

echo.
echo ============================================================
echo   🛑 Frontend kapatıldı
echo ============================================================
echo.
pause
