@echo off
chcp 65001 >nul
echo ╔════════════════════════════════════════════════════════╗
echo ║   Plaka Tanıma Sistemi - Otomatik Kurulum             ║
echo ║   Evo Teknoloji                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

:: Check Python
echo [1/6] Python kontrol ediliyor...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python bulunamadı!
    echo.
    echo Python 3.9 veya üzeri yüklemeniz gerekiyor:
    echo https://www.python.org/downloads/
    echo.
    echo Kurulum sırasında "Add Python to PATH" seçeneğini işaretleyin!
    pause
    exit /b 1
)
echo ✓ Python bulundu
echo.

:: Check Node.js
echo [2/6] Node.js kontrol ediliyor...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js bulunamadı!
    echo.
    echo Node.js 18 veya üzeri yüklemeniz gerekiyor:
    echo https://nodejs.org/
    pause
    exit /b 1
)
echo ✓ Node.js bulundu
echo.

:: Check MongoDB
echo [3/6] MongoDB kontrol ediliyor...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo ⚠ MongoDB bulunamadı!
    echo.
    echo MongoDB Community Edition yüklemeniz önerilir:
    echo https://www.mongodb.com/try/download/community
    echo.
    echo MongoDB olmadan devam etmek ister misiniz? (E/H)
    set /p continue=">"
    if /i not "%continue%"=="E" exit /b 1
) else (
    echo ✓ MongoDB bulundu
)
echo.

:: Check Tesseract
echo [4/6] Tesseract OCR kontrol ediliyor...
tesseract --version >nul 2>&1
if errorlevel 1 (
    echo ⚠ Tesseract OCR bulunamadı!
    echo.
    echo Plaka okuma için Tesseract OCR kurulmalı:
    echo https://github.com/UB-Mannheim/tesseract/wiki
    echo.
    echo Kurulum sırasında "Turkish" dil paketini seçin!
    echo Tesseract olmadan devam etmek ister misiniz? (E/H)
    set /p continue=">"
    if /i not "%continue%"=="E" exit /b 1
) else (
    echo ✓ Tesseract OCR bulundu
)
echo.

:: Install Backend Dependencies
echo [5/6] Backend bağımlılıkları kuruluyor...
cd backend
if exist requirements.txt (
    pip install -r requirements.txt
    if errorlevel 1 (
        echo ❌ Backend bağımlılıkları kurulamadı!
        cd ..
        pause
        exit /b 1
    )
    echo ✓ Backend bağımlılıkları kuruldu
) else (
    echo ❌ requirements.txt bulunamadı!
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

:: Install Frontend Dependencies
echo [6/6] Frontend bağımlılıkları kuruluyor...
cd frontend
if exist package.json (
    call npm install
    if errorlevel 1 (
        echo ⚠ npm install başarısız, yarn deneniyor...
        call yarn install
        if errorlevel 1 (
            echo ❌ Frontend bağımlılıkları kurulamadı!
            cd ..
            pause
            exit /b 1
        )
    )
    echo ✓ Frontend bağımlılıkları kuruldu
) else (
    echo ❌ package.json bulunamadı!
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

:: Setup Environment Files
echo Ortam değişkenleri ayarlanıyor...

if not exist "backend\.env" (
    echo MONGO_URL=mongodb://localhost:27017 > backend\.env
    echo DB_NAME=plaka_tanima_db >> backend\.env
    echo CORS_ORIGINS=http://localhost:3000 >> backend\.env
    echo ✓ backend/.env oluşturuldu
)

if not exist "frontend\.env" (
    echo REACT_APP_BACKEND_URL=http://localhost:8001 > frontend\.env
    echo ✓ frontend/.env oluşturuldu
)

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   ✅ KURULUM TAMAMLANDI!                              ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo Sistemi başlatmak için 'start.bat' dosyasını çalıştırın.
echo.
echo Önemli Notlar:
echo - MongoDB servisinin çalıştığından emin olun
echo - Backend: http://localhost:8001
echo - Frontend: http://localhost:3000
echo.
pause
