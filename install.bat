@echo off
echo ================================================
echo   Plaka Tanima Sistemi - Kurulum
echo   Evo Teknoloji
echo ================================================
echo.

:: Check Python
echo [1/6] Python kontrol ediliyor...
python --version >nul 2>&1
if errorlevel 1 (
    echo HATA: Python bulunamadi!
    echo.
    echo Python 3.9 veya uzeri yuklemeniz gerekiyor:
    echo https://www.python.org/downloads/
    echo.
    echo Kurulum sirasinda "Add Python to PATH" secenegini isaretleyin!
    pause
    exit /b 1
)
echo OK - Python bulundu
echo.

:: Check Node.js
echo [2/6] Node.js kontrol ediliyor...
node --version >nul 2>&1
if errorlevel 1 (
    echo HATA: Node.js bulunamadi!
    echo.
    echo Node.js 18 veya uzeri yuklemeniz gerekiyor:
    echo https://nodejs.org/
    pause
    exit /b 1
)
echo OK - Node.js bulundu
echo.

:: Check MongoDB
echo [3/6] MongoDB kontrol ediliyor...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo UYARI: MongoDB bulunamadi!
    echo.
    echo MongoDB Community Edition yuklemeniz onerilir:
    echo https://www.mongodb.com/try/download/community
    echo.
    echo MongoDB olmadan devam etmek ister misiniz? (E/H)
    set /p continue=">"
    if /i not "%continue%"=="E" exit /b 1
) else (
    echo OK - MongoDB bulundu
)
echo.

:: Check Tesseract
echo [4/6] Tesseract OCR kontrol ediliyor...
tesseract --version >nul 2>&1
if errorlevel 1 (
    echo UYARI: Tesseract OCR bulunamadi!
    echo.
    echo Plaka okuma icin Tesseract OCR kurulmali:
    echo https://github.com/UB-Mannheim/tesseract/wiki
    echo.
    echo Kurulum sirasinda "Turkish" dil paketini secin!
    echo Tesseract olmadan devam etmek ister misiniz? (E/H)
    set /p continue=">"
    if /i not "%continue%"=="E" exit /b 1
) else (
    echo OK - Tesseract OCR bulundu
)
echo.

:: Install Backend Dependencies
echo [5/6] Backend bagimliliklari kuruluyor...
cd backend
if exist requirements.txt (
    pip install -r requirements.txt
    if errorlevel 1 (
        echo HATA: Backend bagimliliklari kurulamadi!
        cd ..
        pause
        exit /b 1
    )
    echo OK - Backend bagimliliklari kuruldu
) else (
    echo HATA: requirements.txt bulunamadi!
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

:: Install Frontend Dependencies
echo [6/6] Frontend bagimliliklari kuruluyor...
cd frontend
if exist package.json (
    call npm install
    if errorlevel 1 (
        echo UYARI: npm install basarisiz, yarn deneniyor...
        call yarn install
        if errorlevel 1 (
            echo HATA: Frontend bagimliliklari kurulamadi!
            cd ..
            pause
            exit /b 1
        )
    )
    echo OK - Frontend bagimliliklari kuruldu
) else (
    echo HATA: package.json bulunamadi!
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

:: Setup Environment Files
echo Ortam degiskenleri ayarlaniyor...

if not exist "backend\.env" (
    echo MONGO_URL=mongodb://localhost:27017 > backend\.env
    echo DB_NAME=plaka_tanima_db >> backend\.env
    echo CORS_ORIGINS=http://localhost:3000 >> backend\.env
    echo OK - backend/.env olusturuldu
)

if not exist "frontend\.env" (
    echo REACT_APP_BACKEND_URL=http://localhost:8001 > frontend\.env
    echo OK - frontend/.env olusturuldu
)

echo.
echo ================================================
echo   KURULUM TAMAMLANDI!
echo ================================================
echo.
echo Sistemi baslatmak icin 'start.bat' dosyasini calistirin.
echo.
echo Onemli Notlar:
echo - MongoDB servisinin calistigindan emin olun
echo - Backend: http://localhost:8001
echo - Frontend: http://localhost:3000
echo.
pause
