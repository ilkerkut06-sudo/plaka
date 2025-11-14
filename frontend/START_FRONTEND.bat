@echo off
chcp 65001 >nul
color 0B
cls

echo ============================================================
echo   🌐 PLAKA OKUMA SİSTEMİ - FRONTEND BAŞLATILIYOR
echo ============================================================
echo.

REM Check if node_modules exists
if not exist "node_modules" (
    echo ❌ HATA: node_modules klasörü bulunamadı!
    echo.
    echo Lütfen önce SETUP_AND_START.bat dosyasını çalıştırın.
    echo.
    pause
    exit /b 1
)

echo ✅ node_modules bulundu
echo.

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
