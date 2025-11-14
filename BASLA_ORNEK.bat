@echo off
echo ================================================
echo   Plaka Tanima Sistemi Baslatiliyor
echo ================================================
echo.

:: MongoDB PATH ayarla
if exist "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\7.0\bin
) else if exist "C:\Program Files\MongoDB\Server\6.0\bin\mongod.exe" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\6.0\bin
) else if exist "C:\Program Files\MongoDB\Server\5.0\bin\mongod.exe" (
    set PATH=%PATH%;C:\Program Files\MongoDB\Server\5.0\bin
)

:: Tesseract PATH ayarla
if exist "C:\Program Files\Tesseract-OCR\tesseract.exe" (
    set PATH=%PATH%;C:\Program Files\Tesseract-OCR
) else if exist "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe" (
    set PATH=%PATH%;C:\Program Files (x86)\Tesseract-OCR
)

:: Onceki surecler
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul

:: MongoDB servisi
echo MongoDB baslatiliyor...
net start MongoDB >nul 2>&1

:: Backend
echo Backend baslatiliyor...
cd backend
if exist venv\Scripts\python.exe (
    start "Plaka Tanima - Backend" cmd /k "venv\Scripts\python.exe server.py"
) else (
    start "Plaka Tanima - Backend" cmd /k "python server.py"
)
cd ..

timeout /t 5 >nul

:: Frontend
echo Frontend baslatiliyor...
cd frontend
start "Plaka Tanima - Frontend" cmd /k "npm start"
cd ..

echo.
echo Sistem baslatildi!
echo Tarayici otomatik acilacak: http://localhost:3000
echo.

timeout /t 5 >nul
start http://localhost:3000

pause
