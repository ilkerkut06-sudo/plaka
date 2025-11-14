@echo off
echo ================================================
echo   Sistem Gereksinimleri Kontrol
echo ================================================
echo.

echo Python:
python --version
if errorlevel 1 (
    echo   [X] BULUNAMADI - https://www.python.org/downloads/
) else (
    echo   [OK]
)
echo.

echo Node.js:
node --version
if errorlevel 1 (
    echo   [X] BULUNAMADI - https://nodejs.org/
) else (
    echo   [OK]
)
echo.

echo MongoDB:
mongod --version
if errorlevel 1 (
    echo   [X] BULUNAMADI - https://www.mongodb.com/try/download/community
) else (
    echo   [OK]
)
echo.

echo Tesseract OCR:
tesseract --version
if errorlevel 1 (
    echo   [X] BULUNAMADI - https://github.com/UB-Mannheim/tesseract/wiki
) else (
    echo   [OK]
)
echo.

echo ================================================
echo Tum gereksinimler OK ise install.bat calistirin
echo ================================================
pause
