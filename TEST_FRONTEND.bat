@echo off
chcp 65001 >nul
color 0E
cls

echo ============================================================
echo   🧪 FRONTEND TEST ARACI
echo ============================================================
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo 📂 Test dizini: %CD%
echo.

echo [1/5] Node.js kontrolü...
where node >nul 2>&1
if errorlevel 1 (
    echo   ❌ Node.js BULUNAMADI!
    echo   📥 İndirmek için: https://nodejs.org/
) else (
    echo   ✅ Node.js bulundu
    node --version
)
echo.

echo [2/5] NPM kontrolü...
where npm >nul 2>&1
if errorlevel 1 (
    echo   ❌ NPM BULUNAMADI!
) else (
    echo   ✅ NPM bulundu
    npm --version
)
echo.

echo [3/5] node_modules kontrolü...
if exist "frontend\node_modules" (
    echo   ✅ node_modules bulundu
) else (
    echo   ❌ node_modules BULUNAMADI!
    echo   📂 Aranan: %CD%\frontend\node_modules
)
echo.

echo [4/5] package.json kontrolü...
if exist "frontend\package.json" (
    echo   ✅ package.json bulundu
    echo.
    echo   Proje bilgileri:
    findstr /c:"\"name\":" /c:"\"version\":" "frontend\package.json"
) else (
    echo   ❌ package.json BULUNAMADI!
)
echo.

echo [5/5] .env dosyası kontrolü...
if exist "frontend\.env" (
    echo   ✅ .env bulundu
    echo.
    echo   Backend URL:
    findstr "REACT_APP_BACKEND_URL" "frontend\.env"
) else (
    echo   ⚠️  .env BULUNAMADI!
    echo   Varsayılan ayarlar kullanılacak
)
echo.

echo ============================================================
echo   📊 TEST SONUCU
echo ============================================================
echo.

where node >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js kurulu değil - frontend başlatılamaz
    echo.
    echo 💡 Çözüm: Node.js'i indirin ve kurun
    echo 📥 https://nodejs.org/
    goto :end
)

if exist "frontend\node_modules" if exist "frontend\package.json" (
    echo ✅ Frontend başlatılmaya HAZIR!
    echo.
    echo 🚀 Başlatmak için: frontend\START_FRONTEND.bat
) else (
    echo ❌ Frontend başlatılamaz - yukarıdaki hataları düzeltin
    echo.
    echo 💡 Çözüm: SETUP_AND_START.bat dosyasını çalıştırın
)

:end
echo.
pause
