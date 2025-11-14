@echo off
color 0E
cls
echo ================================================
echo   BACKEND TAMIRI - Adim Adim
echo ================================================
echo.

cd backend

echo [1/5] Eski venv siliniyor...
if exist venv (
    rmdir /s /q venv
    echo   OK - Eski venv silindi
) else (
    echo   OK - Zaten yoktu
)
echo.
pause

echo [2/5] Yeni venv olusturuluyor...
py -m venv venv
if errorlevel 1 (
    echo HATA: venv olusturulamadi!
    pause
    exit /b 1
)

if not exist venv\Scripts\python.exe (
    echo HATA: python.exe olusturulamadi!
    pause
    exit /b 1
)
echo   OK - venv olusturuldu
echo.
pause

echo [3/5] pip guncelleniyor...
venv\Scripts\python.exe -m pip install --upgrade pip
echo   OK - pip guncellendi
echo.
pause

echo [4/5] Paketler kuruluyor... (5-10 dakika)
echo   LUTFEN BEKLEYIN!
echo.
venv\Scripts\python.exe -m pip install fastapi motor pydantic python-dotenv uvicorn opencv-python-headless psutil ultralytics pytesseract pillow easyocr "numpy<2.0.0" requests websockets
if errorlevel 1 (
    echo.
    echo HATA: Paketler kurulamaadi!
    echo Internet baglantinizi kontrol edin.
    pause
    exit /b 1
)
echo   OK - Paketler kuruldu
echo.
pause

echo [5/5] .env dosyasi kontrol ediliyor...
if not exist .env (
    echo MONGO_URL=mongodb://localhost:27017 > .env
    echo DB_NAME=plaka_tanima_db >> .env
    echo CORS_ORIGINS=http://localhost:3000 >> .env
    echo   OK - .env olusturuldu
) else (
    echo   OK - .env zaten var
)
echo.

echo ================================================
echo   BACKEND HAZIR!
echo ================================================
echo.
echo MongoDB kontrol ediliyor...
net start MongoDB >nul 2>&1
echo.
echo Simdi backend baslatiliyor...
echo HATA VARSA GORECEKSINIZ!
echo.
pause

echo.
echo ================================================
echo BACKEND BASLATILIYOR...
echo ================================================
echo.

venv\Scripts\python.exe server.py
if errorlevel 1 (
    echo.
    echo HATA: Backend baslatilamadi!
    echo Yukaridaki hata mesajini okuyun.
)

echo.
echo Backend kapandi veya hata aldi.
pause
