@echo off
chcp 65001 >nul
echo ╔════════════════════════════════════════════════════════╗
echo ║   Plaka Tanıma Sistemi Başlatılıyor                   ║
echo ║   Evo Teknoloji                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

:: Check MongoDB
echo MongoDB kontrol ediliyor...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo ⚠ MongoDB bulunamadı veya çalışmıyor!
    echo MongoDB'yi başlatmayı deneyin: net start MongoDB
    echo.
)

:: Create data directory for MongoDB if needed
if not exist "C:\data\db" (
    echo MongoDB veri klasörü oluşturuluyor...
    mkdir "C:\data\db" >nul 2>&1
)

:: Kill existing processes
echo Önceki süreçler temizleniyor...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul

:: Start Backend
echo.
echo [1/2] Backend başlatılıyor...
cd backend
start "Plaka Tanıma - Backend" cmd /k "python server.py"
cd ..
echo ✓ Backend başlatıldı (Port: 8001)

:: Wait for backend to start
echo Backend hazırlanıyor...
timeout /t 5 >nul

:: Start Frontend
echo.
echo [2/2] Frontend başlatılıyor...
cd frontend
start "Plaka Tanıma - Frontend" cmd /k "npm start"
cd ..
echo ✓ Frontend başlatıldı (Port: 3000)

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   ✅ SİSTEM BAŞLATILDI!                               ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo Tarayıcınızda otomatik olarak açılacak:
echo http://localhost:3000
echo.
echo Backend API: http://localhost:8001
echo.
echo Kapatmak için açılan terminal pencerelerini kapatın.
echo.

:: Wait and open browser
timeout /t 5 >nul
start http://localhost:3000

echo Sistem çalışıyor... Bu pencereyi kapatabilirsiniz.
pause
