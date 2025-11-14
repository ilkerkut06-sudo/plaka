@echo off
color 0A
cls
echo ================================================
echo   SISTEM BASLATILIYOR
echo ================================================
echo.

echo [1/3] MongoDB baslatiliyor...
net start MongoDB >nul 2>&1
if errorlevel 1 (
    echo   MongoDB zaten calisiyor veya baslatılamadı
) else (
    echo   [OK] MongoDB baslatildi
)
timeout /t 2 >nul
echo.

echo [2/3] Backend baslatiliyor...
cd backend
start "BACKEND - Plaka Tanima" cmd /k "START_BACKEND.bat"
cd ..
echo   [OK] Backend terminal acildi
timeout /t 5 >nul
echo.

echo [3/3] Frontend baslatiliyor...
cd frontend
start "FRONTEND - Plaka Tanima" cmd /k "npm start"
cd ..
echo   [OK] Frontend terminal acildi
echo.

timeout /t 10 >nul
start http://localhost:3000

echo ================================================
echo   SISTEM BASLATILDI!
echo ================================================
echo.
echo 2 terminal penceresi acti:
echo 1. BACKEND  - Burada hata var mi kontrol edin!
echo 2. FRONTEND
echo.
echo Tarayici acilacak: http://localhost:3000
echo.
echo Backend calismiyorsa:
echo - Backend terminalinde hata mesajini okuyun
echo - MongoDB calistigından emin olun
echo.
pause
