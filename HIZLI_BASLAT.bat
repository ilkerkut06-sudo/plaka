@echo off
chcp 65001 >nul
cls

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║       PLAKA OKUMA SİSTEMİ - HIZLI BAŞLATMA                ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo Hangi servisi başlatmak istersiniz?
echo.
echo   1. Her şeyi başlat (Backend + Frontend + MongoDB)
echo   2. Sadece Backend
echo   3. Sadece Frontend
echo   4. Test Backend
echo   5. Test Frontend
echo   6. Sorun Giderme
echo   7. Çıkış
echo.
echo ════════════════════════════════════════════════════════════
set /p choice="Seçiminiz (1-7): "

if "%choice%"=="1" goto :all
if "%choice%"=="2" goto :backend
if "%choice%"=="3" goto :frontend
if "%choice%"=="4" goto :test_backend
if "%choice%"=="5" goto :test_frontend
if "%choice%"=="6" goto :troubleshoot
if "%choice%"=="7" goto :exit
goto :invalid

:all
cls
echo.
echo 🚀 TÜM SERVİSLER BAŞLATILIYOR...
echo.
call START_ALL.bat
goto :end

:backend
cls
echo.
echo 🔧 BACKEND BAŞLATILIYOR...
echo.
cd backend
call START_BACKEND.bat
cd ..
goto :end

:frontend
cls
echo.
echo 🌐 FRONTEND BAŞLATILIYOR...
echo.
cd frontend
call START_FRONTEND.bat
cd ..
goto :end

:test_backend
cls
echo.
echo 🧪 BACKEND TEST EDİLİYOR...
echo.
call TEST_BACKEND.bat
goto :end

:test_frontend
cls
echo.
echo 🧪 FRONTEND TEST EDİLİYOR...
echo.
call TEST_FRONTEND.bat
goto :end

:troubleshoot
cls
echo.
echo 🔧 SORUN GİDERME ARACI BAŞLATILIYOR...
echo.
call SORUN_GIDER.bat
goto :end

:invalid
cls
color 0C
echo.
echo ❌ Geçersiz seçim! Lütfen 1-7 arası bir sayı girin.
echo.
timeout /t 3 >nul
goto :end

:exit
cls
echo.
echo 👋 Çıkış yapılıyor...
echo.
exit /b 0

:end
echo.
pause
exit /b 0
