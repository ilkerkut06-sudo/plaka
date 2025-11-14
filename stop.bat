@echo off
echo ================================================
echo   Plaka Tanima Sistemi Durduruluyor
echo ================================================
echo.

echo Backend ve Frontend kapatiliyor...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1

echo.
echo OK - Sistem durduruldu.
echo.
pause
