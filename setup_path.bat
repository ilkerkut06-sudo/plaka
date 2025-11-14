@echo off
echo ================================================
echo   PATH Ayarlama - Kalici Cozum
echo ================================================
echo.
echo Bu script MongoDB ve Tesseract'i Windows PATH'ine
echo kalici olarak ekler.
echo.
echo UYARI: Yonetici (Administrator) olarak calistirilmalidir!
echo.
pause

:: Check for admin rights
net session >nul 2>&1
if errorlevel 1 (
    echo HATA: Bu script yonetici olarak calistirilmalidir!
    echo.
    echo Sag tiklayip "Yonetici olarak calistir" secin.
    pause
    exit /b 1
)

echo Yonetici yetkileri onaylandi.
echo.

:: Find MongoDB
set MONGODB_PATH=
if exist "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" (
    set MONGODB_PATH=C:\Program Files\MongoDB\Server\7.0\bin
    echo MongoDB 7.0 bulundu
) else if exist "C:\Program Files\MongoDB\Server\6.0\bin\mongod.exe" (
    set MONGODB_PATH=C:\Program Files\MongoDB\Server\6.0\bin
    echo MongoDB 6.0 bulundu
) else if exist "C:\Program Files\MongoDB\Server\5.0\bin\mongod.exe" (
    set MONGODB_PATH=C:\Program Files\MongoDB\Server\5.0\bin
    echo MongoDB 5.0 bulundu
) else (
    echo MongoDB bulunamadi
)

:: Find Tesseract
set TESSERACT_PATH=
if exist "C:\Program Files\Tesseract-OCR\tesseract.exe" (
    set TESSERACT_PATH=C:\Program Files\Tesseract-OCR
    echo Tesseract OCR bulundu (Program Files)
) else if exist "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe" (
    set TESSERACT_PATH=C:\Program Files (x86)\Tesseract-OCR
    echo Tesseract OCR bulundu (Program Files x86)
) else if exist "C:\Tesseract-OCR\tesseract.exe" (
    set TESSERACT_PATH=C:\Tesseract-OCR
    echo Tesseract OCR bulundu (C:\)
) else (
    echo Tesseract OCR bulunamadi
)

echo.
echo ================================================

:: Add MongoDB to PATH
if defined MONGODB_PATH (
    echo MongoDB PATH'e ekleniyor...
    setx /M PATH "%PATH%;%MONGODB_PATH%" >nul 2>&1
    if errorlevel 1 (
        echo HATA: MongoDB PATH'e eklenemedi!
    ) else (
        echo OK - MongoDB PATH'e eklendi
    )
)

:: Add Tesseract to PATH
if defined TESSERACT_PATH (
    echo Tesseract PATH'e ekleniyor...
    setx /M PATH "%PATH%;%TESSERACT_PATH%" >nul 2>&1
    if errorlevel 1 (
        echo HATA: Tesseract PATH'e eklenemedi!
    ) else (
        echo OK - Tesseract PATH'e eklendi
    )
)

echo.
echo ================================================
echo   TAMAMLANDI!
echo ================================================
echo.
echo Degisikliklerin etkili olmasi icin:
echo 1. Acik olan tum terminal pencerelerini kapatin
echo 2. Yeni bir terminal penceresi acin
echo 3. Test edin:
echo    - mongod --version
echo    - tesseract --version
echo.
pause
