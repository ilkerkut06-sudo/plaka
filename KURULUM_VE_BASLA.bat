@echo off
color 0A
cls

echo.
echo ================================================
echo   PLAKA TANIMA - ONE CLICK SETUP
echo ================================================
echo.
echo   Please wait 10-15 minutes...
echo.
echo ================================================
echo.
pause

:: ============================================
:: ADIM 1: GEREKSINIMLER KONTROL
:: ============================================
echo.
echo [1/7] Gereksinimler kontrol ediliyor...
echo.

python --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo HATA: Python bulunamadi!
    echo.
    echo Python yukleyin: https://www.python.org/downloads/
    echo "Add Python to PATH" secenegini isaretleyin!
    pause
    exit /b 1
)
echo   [OK] Python bulundu

node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo HATA: Node.js bulunamadi!
    echo.
    echo Node.js yukleyin: https://nodejs.org/
    pause
    exit /b 1
)
echo   [OK] Node.js bulundu

:: MongoDB PATH'e ekle
if exist "C:\Program Files\MongoDB\Server\7.0\bin" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\7.0\bin
) else if exist "C:\Program Files\MongoDB\Server\6.0\bin" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\6.0\bin
)

:: Tesseract PATH'e ekle
if exist "C:\Program Files\Tesseract-OCR" (
    set PATH=%PATH%;C:\Program Files\Tesseract-OCR
) else if exist "C:\Program Files (x86)\Tesseract-OCR" (
    set PATH=%PATH%;C:\Program Files (x86)\Tesseract-OCR
)

echo.
echo   Gereksinimler OK!
timeout /t 2 >nul

:: ============================================
:: ADIM 2: MONGODB BASLATMA
:: ============================================
echo.
echo [2/7] MongoDB baslatiliyor...
echo.

net start MongoDB >nul 2>&1
if errorlevel 1 (
    echo   [UYARI] MongoDB servisi baslatılamadi
    echo   MongoDB zaten calisıyor olabilir (sorun degil^)
) else (
    echo   [OK] MongoDB baslatildi
)

timeout /t 2 >nul

:: ============================================
:: ADIM 3: BACKEND KURULUM
:: ============================================
echo.
echo [3/7] Backend kuruluyor... (5-10 dakika surebilir^)
echo.

cd backend

:: Eski venv varsa sil
if exist venv (
    echo   Eski venv temizleniyor...
    rmdir /s /q venv
)

:: Yeni venv olustur
echo   Virtual environment olusturuluyor...
python -m venv venv
if errorlevel 1 (
    color 0C
    echo.
    echo HATA: Virtual environment olusturulamadi!
    pause
    exit /b 1
)

:: pip guncelle
echo   pip guncelleniyor...
venv\Scripts\python.exe -m pip install --upgrade pip --quiet

:: Paketleri kur
echo   Backend paketleri kuruluyor... LUTFEN BEKLEYIN!
venv\Scripts\python.exe -m pip install -r requirements.txt --quiet
if errorlevel 1 (
    color 0C
    echo.
    echo HATA: Backend paketleri kurulamadi!
    echo.
    echo Internet baglantinizi kontrol edin.
    pause
    exit /b 1
)

echo   [OK] Backend kuruldu

:: .env olustur
if not exist .env (
    echo   .env olusturuluyor...
    echo MONGO_URL=mongodb://localhost:27017 > .env
    echo DB_NAME=plaka_tanima_db >> .env
    echo CORS_ORIGINS=http://localhost:3000 >> .env
)

cd ..
timeout /t 2 >nul

:: ============================================
:: ADIM 4: FRONTEND KURULUM
:: ============================================
echo.
echo [4/7] Frontend kuruluyor... (5-10 dakika surebilir^)
echo.

cd frontend

:: Eski node_modules varsa sil
if exist node_modules (
    echo   Eski node_modules temizleniyor...
    rmdir /s /q node_modules
)

:: Cache temizle
echo   npm cache temizleniyor...
call npm cache clean --force >nul 2>&1

:: Paketleri kur
echo   Frontend paketleri kuruluyor... LUTFEN BEKLEYIN!
call npm install --legacy-peer-deps --silent
if errorlevel 1 (
    color 0C
    echo.
    echo HATA: Frontend paketleri kurulamadi!
    echo.
    echo Internet baglantinizi kontrol edin.
    pause
    exit /b 1
)

echo   [OK] Frontend kuruldu

:: .env olustur
if not exist .env (
    echo   .env olusturuluyor...
    echo REACT_APP_BACKEND_URL=http://localhost:8001 > .env
)

cd ..
timeout /t 2 >nul

:: ============================================
:: ADIM 5: BASLAT SCRIPTLERI OLUSTUR
:: ============================================
echo.
echo [5/7] Baslatma scriptleri olusturuluyor...
echo.

:: Backend baslatma
echo @echo off > BASLA_BACKEND.bat
echo cd backend >> BASLA_BACKEND.bat
echo call venv\Scripts\activate >> BASLA_BACKEND.bat
echo python server.py >> BASLA_BACKEND.bat
echo pause >> BASLA_BACKEND.bat

:: Frontend baslatma
echo @echo off > BASLA_FRONTEND.bat
echo cd frontend >> BASLA_FRONTEND.bat
echo npm start >> BASLA_FRONTEND.bat
echo pause >> BASLA_FRONTEND.bat

echo   [OK] Scriptler olusturuldu

timeout /t 2 >nul

:: ============================================
:: ADIM 6: BACKEND BASLAT
:: ============================================
echo.
echo [6/7] Backend baslatiliyor...
echo.

cd backend
start "PLAKA TANIMA - BACKEND" cmd /k "call venv\Scripts\activate && python server.py"
cd ..

echo   [OK] Backend terminal penceresi acildi
echo   Backend hazirlanıyor...

timeout /t 8 >nul

:: ============================================
:: ADIM 7: FRONTEND BASLAT
:: ============================================
echo.
echo [7/7] Frontend baslatiliyor...
echo.

cd frontend
start "PLAKA TANIMA - FRONTEND" cmd /k "npm start"
cd ..

echo   [OK] Frontend terminal penceresi acildi

timeout /t 3 >nul

:: ============================================
:: BASARILI
:: ============================================
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════
echo   KURULUM VE BASLATMA TAMAMLANDI!
echo ═══════════════════════════════════════════════════════════
echo.
echo   2 terminal penceresi acildi:
echo   1. Backend  (port 8001^)
echo   2. Frontend (port 3000^)
echo.
echo   Tarayicinizda 30 saniye icinde acilacak:
echo   http://localhost:3000
echo.
echo   ONEMLI: Terminal pencerelerini KAPATMAYIN!
echo.
echo ═══════════════════════════════════════════════════════════
echo.
echo   Gelecekte sistemi baslatmak icin:
echo   - BASLA_BACKEND.bat
echo   - BASLA_FRONTEND.bat
echo.
echo ═══════════════════════════════════════════════════════════
echo.

:: Tarayici ac
timeout /t 10 >nul
start http://localhost:3000

echo   Sistem calisiyor!
echo.
pause
