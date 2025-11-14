@echo off
chcp 65001 >nul
echo ╔════════════════════════════════════════════════════════╗
echo ║   Plaka Tanıma Sistemi Durduruluyor                   ║
echo ╚════════════════════════════════════════════════════════╝
echo.

echo Backend ve Frontend kapatılıyor...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1

echo.
echo ✓ Sistem durduruldu.
echo.
pause
