@echo off
color 0B
echo ================================================
echo   BACKEND TEST
echo ================================================
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

echo [TEST 5] MongoDB calisiyor mu?
net start MongoDB >nul 2>&1
mongod --version >nul 2>&1
if errorlevel 1 (
    echo   [UYARI] MongoDB bulunamadi
    echo   MongoDB kurun veya PATH'e ekleyin
) else (
    echo   [OK] MongoDB bulundu
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
venv\Scripts\python.exe server.py
echo ================================================
echo.
pause
