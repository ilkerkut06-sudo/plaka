@echo off
chcp 65001 >nul
color 0E
cls

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ============================================================
echo   🧪 BACKEND TEST ARACI
echo ============================================================
echo.
echo 📂 Test dizini: %CD%
echo.

cd backend

echo [TEST 1] python.exe var mi?
if exist venv\Scripts\python.exe (
    echo   [OK] python.exe bulundu
) else (
    echo   [HATA] python.exe YOK!
    echo   FIX_BACKEND.bat calistirin
    pause
    exit /b 1
)
echo.

echo [TEST 2] server.py var mi?
if exist server.py (
    echo   [OK] server.py bulundu
) else (
    echo   [HATA] server.py YOK!
    pause
    exit /b 1
)
echo.

echo [TEST 3] .env var mi?
if exist .env (
    echo   [OK] .env bulundu
    type .env
) else (
    echo   [HATA] .env YOK!
    echo MONGO_URL=mongodb://localhost:27017 > .env
    echo DB_NAME=plaka_tanima_db >> .env
    echo CORS_ORIGINS=http://localhost:3000 >> .env
    echo   [FIX] .env olusturuldu
)
echo.

echo [TEST 4] Paketler kurulu mu?
venv\Scripts\python.exe -c "import fastapi; print('  [OK] fastapi kurulu')"
if errorlevel 1 (
    echo   [HATA] fastapi kurulu degil!
    pause
    exit /b 1
)
echo.

echo [TEST 5] MongoDB baslatiliyor...
"C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" --version >nul 2>&1
if errorlevel 1 (
    echo   [UYARI] MongoDB 7.0 bulunamadi
    "C:\Program Files\MongoDB\Server\6.0\bin\mongod.exe" --version >nul 2>&1
    if errorlevel 1 (
        echo   [HATA] MongoDB kurulu degil!
        pause
        exit /b 1
    )
)

net start MongoDB >nul 2>&1
if errorlevel 1 (
    echo   [UYARI] MongoDB servisi baslatilamadi
    echo   MongoDB zaten calisiyor olabilir
) else (
    echo   [OK] MongoDB servisi baslatildi
)
echo.

echo [TEST 6] Port 8001 bos mu?
netstat -ano | findstr :8001 >nul
if errorlevel 1 (
    echo   [OK] Port 8001 bos
) else (
    echo   [UYARI] Port 8001 kullaniliyor
    echo   Baska program kullanıyor olabilir
)
echo.

echo ================================================
echo   TESTLER TAMAMLANDI
echo ================================================
echo.
echo Simdi backend manuel baslatiliyor...
echo HATA GORURSENIZ EKRAN GORUNTUSU ALIN!
echo.
pause

echo.
echo ================================================
color 0A
echo BASLATILIYOR...
echo.
venv\Scripts\python.exe -u server.py
echo.
echo ================================================
echo Backend kapandi!
echo Yukarida hata var mi kontrol edin.
echo ================================================
echo.
pause
