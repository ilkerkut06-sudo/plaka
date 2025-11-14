@echo off
echo ================================================
echo   HIZLI KURULUM (Timeout Sorunu Varsa)
echo ================================================
echo.
echo Bu script timeout sorunlariniz varsa kullanin.
echo.
pause

:: Backend
echo.
echo [1/2] Backend kuruluyor...
cd backend

if not exist venv (
    echo Virtual environment olusturuluyor...
    python -m venv venv
)

echo pip guncelleniyor...
venv\Scripts\pip.exe install --upgrade pip

echo Backend paketleri kuruluyor...
venv\Scripts\pip.exe install -r requirements.txt

if errorlevel 1 (
    echo HATA: Backend kurulumu basarisiz!
    cd ..
    pause
    exit /b 1
)

cd ..
echo Backend kuruldu!

:: Frontend
echo.
echo [2/2] Frontend kuruluyor...
cd frontend

:: Yarn varsa kullan
where yarn >nul 2>&1
if %errorlevel% equ 0 (
    echo Yarn ile kurulum yapiliyor...
    call yarn install
) else (
    echo npm ile kurulum yapiliyor...
    call npm install --legacy-peer-deps
)

if errorlevel 1 (
    echo HATA: Frontend kurulumu basarisiz!
    cd ..
    pause
    exit /b 1
)

cd ..
echo Frontend kuruldu!

:: Env dosyalari
echo.
echo Ortam dosyalari olusturuluyor...

if not exist backend\.env (
    echo MONGO_URL=mongodb://localhost:27017 > backend\.env
    echo DB_NAME=plaka_tanima_db >> backend\.env
    echo CORS_ORIGINS=http://localhost:3000 >> backend\.env
    echo backend/.env olusturuldu
)

if not exist frontend\.env (
    echo REACT_APP_BACKEND_URL=http://localhost:8001 > frontend\.env
    echo frontend/.env olusturuldu
)

:: BASLA.bat olustur
echo.
echo BASLA.bat olusturuluyor...

echo @echo off > BASLA.bat
echo echo Plaka Tanima Sistemi Baslatiliyor... >> BASLA.bat
echo echo. >> BASLA.bat
echo. >> BASLA.bat
echo :: MongoDB PATH >> BASLA.bat
echo if exist "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" set PATH=%%PATH%%;C:\Program Files\MongoDB\Server\7.0\bin >> BASLA.bat
echo if exist "C:\Program Files\MongoDB\Server\6.0\bin\mongod.exe" set PATH=%%PATH%%;C:\Program Files\MongoDB\Server\6.0\bin >> BASLA.bat
echo if exist "C:\Program Files\MongoDB\Server\5.0\bin\mongod.exe" set PATH=%%PATH%%;C:\Program Files\MongoDB\Server\5.0\bin >> BASLA.bat
echo. >> BASLA.bat
echo :: Tesseract PATH >> BASLA.bat
echo if exist "C:\Program Files\Tesseract-OCR\tesseract.exe" set PATH=%%PATH%%;C:\Program Files\Tesseract-OCR >> BASLA.bat
echo if exist "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe" set PATH=%%PATH%%;C:\Program Files (x86)\Tesseract-OCR >> BASLA.bat
echo. >> BASLA.bat
echo :: MongoDB servisi >> BASLA.bat
echo net start MongoDB ^>nul 2^>^&1 >> BASLA.bat
echo. >> BASLA.bat
echo :: Onceki surecler >> BASLA.bat
echo taskkill /F /IM python.exe ^>nul 2^>^&1 >> BASLA.bat
echo taskkill /F /IM node.exe ^>nul 2^>^&1 >> BASLA.bat
echo timeout /t 2 ^>nul >> BASLA.bat
echo. >> BASLA.bat
echo :: Backend >> BASLA.bat
echo cd backend >> BASLA.bat
echo start "Backend" cmd /k "venv\Scripts\python.exe server.py" >> BASLA.bat
echo cd .. >> BASLA.bat
echo timeout /t 5 ^>nul >> BASLA.bat
echo. >> BASLA.bat
echo :: Frontend >> BASLA.bat
echo cd frontend >> BASLA.bat
echo start "Frontend" cmd /k "npm start" >> BASLA.bat
echo cd .. >> BASLA.bat
echo timeout /t 5 ^>nul >> BASLA.bat
echo start http://localhost:3000 >> BASLA.bat
echo pause >> BASLA.bat

echo.
echo ================================================
echo   KURULUM TAMAMLANDI!
echo ================================================
echo.
echo Sistemi baslatmak icin: BASLA.bat
echo.
pause
