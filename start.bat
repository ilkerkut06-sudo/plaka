@echo off
echo ================================================
echo   Plaka Tanima Sistemi Baslatiliyor
echo   Evo Teknoloji
echo ================================================
echo.

:: Setup MongoDB PATH
if exist "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\7.0\bin
) else if exist "C:\Program Files\MongoDB\Server\6.0\bin\mongod.exe" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\6.0\bin
) else if exist "C:\Program Files\MongoDB\Server\5.0\bin\mongod.exe" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\5.0\bin
)

:: Setup Tesseract PATH
if exist "C:\Program Files\Tesseract-OCR\tesseract.exe" (
    set PATH=%PATH%;C:\Program Files\Tesseract-OCR
) else if exist "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe" (
    set PATH=%PATH%;C:\Program Files (x86)\Tesseract-OCR
) else if exist "C:\Tesseract-OCR\tesseract.exe" (
    set PATH=%PATH%;C:\Tesseract-OCR
)

:: Check MongoDB
echo MongoDB kontrol ediliyor...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo UYARI: MongoDB bulunamadi!
    echo MongoDB'yi manuel baslatabilirsiniz: net start MongoDB
    echo.
) else (
    echo OK - MongoDB hazir
)

:: Create data directory for MongoDB if needed
if not exist "C:\data\db" (
    echo MongoDB veri klasoru olusturuluyor...
    mkdir "C:\data\db" >nul 2>&1
)

:: Kill existing processes
echo Onceki surecler temizleniyor...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul

:: Start Backend
echo.
echo [1/2] Backend baslatiliyor...
cd backend
start "Plaka Tanima - Backend" cmd /k "python server.py"
cd ..
echo OK - Backend baslatildi (Port: 8001)

:: Wait for backend to start
echo Backend hazirlaniyor...
timeout /t 5 >nul

:: Start Frontend
echo.
echo [2/2] Frontend baslatiliyor...
cd frontend
start "Plaka Tanima - Frontend" cmd /k "npm start"
cd ..
echo OK - Frontend baslatildi (Port: 3000)

echo.
echo ================================================
echo   SISTEM BASLATILDI!
echo ================================================
echo.
echo Tarayicinizda otomatik olarak acilacak:
echo http://localhost:3000
echo.
echo Backend API: http://localhost:8001
echo.
echo Kapatmak icin acilan terminal pencerelerini kapatin.
echo.

:: Wait and open browser
timeout /t 5 >nul
start http://localhost:3000

echo Sistem calisiyor... Bu pencereyi kapatabilirsiniz.
pause
