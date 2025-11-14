@echo off
chcp 65001 >nul
color 0C
cls

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ============================================================
echo   🔧 SORUN GİDERME ARACI
echo ============================================================
echo.
echo Bu araç sisteminizi kontrol edip sorunları tespit eder.
echo.
pause

cls
echo ============================================================
echo   📋 SİSTEM KONTROLÜ BAŞLIYOR...
echo ============================================================
echo.

REM 1. Dizin kontrolü
echo [1/8] 📂 Dizin yapısı kontrolü...
echo   Ana dizin: %CD%
if exist "backend" (
    echo   ✅ backend klasörü var
) else (
    echo   ❌ backend klasörü YOK!
)
if exist "frontend" (
    echo   ✅ frontend klasörü var
) else (
    echo   ❌ frontend klasörü YOK!
)
echo.

REM 2. Python kontrolü
echo [2/8] 🐍 Python kontrolü...
where python >nul 2>&1
if errorlevel 1 (
    where py >nul 2>&1
    if errorlevel 1 (
        echo   ❌ Python BULUNAMADI!
        echo   📥 İndirmek için: https://www.python.org/downloads/
    ) else (
        echo   ✅ Python bulundu (py komutuyla)
        py --version
    )
) else (
    echo   ✅ Python bulundu
    python --version
)
echo.

REM 3. Node.js kontrolü
echo [3/8] 🟢 Node.js kontrolü...
where node >nul 2>&1
if errorlevel 1 (
    echo   ❌ Node.js BULUNAMADI!
    echo   📥 İndirmek için: https://nodejs.org/
) else (
    echo   ✅ Node.js bulundu
    node --version
    npm --version
)
echo.

REM 4. MongoDB kontrolü
echo [4/8] 🍃 MongoDB kontrolü...
where mongod >nul 2>&1
if errorlevel 1 (
    echo   ⚠️  MongoDB PATH'te yok
    if exist "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" (
        echo   ✅ MongoDB 7.0 kurulu
    ) else if exist "C:\Program Files\MongoDB\Server\6.0\bin\mongod.exe" (
        echo   ✅ MongoDB 6.0 kurulu
    ) else (
        echo   ❌ MongoDB BULUNAMADI!
        echo   📥 İndirmek için: https://www.mongodb.com/try/download/community
    )
) else (
    echo   ✅ MongoDB PATH'te
    mongod --version | findstr "version"
)

REM MongoDB servisi kontrolü
net start | findstr "MongoDB" >nul
if errorlevel 1 (
    echo   ⚠️  MongoDB servisi çalışmıyor
    echo   🔄 Başlatılıyor...
    net start MongoDB >nul 2>&1
    if errorlevel 1 (
        echo   ❌ MongoDB servisi başlatılamadı
        echo   💡 Yönetici olarak çalıştırın veya manuel başlatın
    ) else (
        echo   ✅ MongoDB servisi başlatıldı
    )
) else (
    echo   ✅ MongoDB servisi çalışıyor
)
echo.

REM 5. Backend dosyaları kontrolü
echo [5/8] 📁 Backend dosyaları kontrolü...
if exist "backend\venv\Scripts\python.exe" (
    echo   ✅ Virtual environment var
) else (
    echo   ❌ Virtual environment YOK!
)
if exist "backend\server.py" (
    echo   ✅ server.py var
) else (
    echo   ❌ server.py YOK!
)
if exist "backend\.env" (
    echo   ✅ .env var
) else (
    echo   ❌ .env YOK!
)
if exist "backend\requirements.txt" (
    echo   ✅ requirements.txt var
) else (
    echo   ❌ requirements.txt YOK!
)
echo.

REM 6. Frontend dosyaları kontrolü
echo [6/8] 📁 Frontend dosyaları kontrolü...
if exist "frontend\node_modules" (
    echo   ✅ node_modules var
) else (
    echo   ❌ node_modules YOK!
)
if exist "frontend\package.json" (
    echo   ✅ package.json var
) else (
    echo   ❌ package.json YOK!
)
if exist "frontend\.env" (
    echo   ✅ .env var
) else (
    echo   ❌ .env YOK!
)
if exist "frontend\src\App.jsx" (
    echo   ✅ src/App.jsx var
) else (
    echo   ❌ src/App.jsx YOK!
)
echo.

REM 7. Port kontrolü
echo [7/8] 🔌 Port kullanımı kontrolü...
netstat -ano | findstr :8001 >nul
if errorlevel 1 (
    echo   ✅ Port 8001 müsait (Backend için)
) else (
    echo   ⚠️  Port 8001 kullanımda
    echo   💡 Backend zaten çalışıyor olabilir
)

netstat -ano | findstr :3000 >nul
if errorlevel 1 (
    echo   ✅ Port 3000 müsait (Frontend için)
) else (
    echo   ⚠️  Port 3000 kullanımda
    echo   💡 Frontend zaten çalışıyor olabilir
)
echo.

REM 8. Başlatma scriptleri kontrolü
echo [8/8] 📜 Başlatma scriptleri kontrolü...
if exist "backend\START_BACKEND.bat" (
    echo   ✅ START_BACKEND.bat var
) else (
    echo   ❌ START_BACKEND.bat YOK!
)
if exist "frontend\START_FRONTEND.bat" (
    echo   ✅ START_FRONTEND.bat var
) else (
    echo   ❌ START_FRONTEND.bat YOK!
)
if exist "START_ALL.bat" (
    echo   ✅ START_ALL.bat var
) else (
    echo   ❌ START_ALL.bat YOK!
)
echo.

echo ============================================================
echo   📊 KONTROL TAMAMLANDI
echo ============================================================
echo.
echo 🔍 Eksik bileşenler varsa yukarıda ❌ ile işaretlenmiştir.
echo.
echo 💡 ÖNERİLER:
echo.
echo   1. Eksik yazılımları indirin ve kurun
echo   2. SETUP_AND_START.bat dosyasını çalıştırın
echo   3. Sorun devam ederse:
echo      - NASIL_KULLANILIR.txt dosyasına bakın
echo      - TEST_BACKEND.bat ve TEST_FRONTEND.bat çalıştırın
echo.
echo ============================================================
pause
