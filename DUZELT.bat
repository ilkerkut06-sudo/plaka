@echo off
echo ================================================
echo   Frontend Bagimliliklarini Duzeltiyor
echo ================================================
echo.

cd frontend

echo node_modules temizleniyor...
if exist node_modules (
    rmdir /s /q node_modules
)

echo npm cache temizleniyor...
call npm cache clean --force

echo Paketler yeniden kuruluyor...
call npm install --legacy-peer-deps

if errorlevel 1 (
    echo.
    echo HATA: Paketler kurulamadi!
    cd ..
    pause
    exit /b 1
)

echo.
echo ajv paketi kontrol ediliyor...
if not exist "node_modules\ajv" (
    echo ajv eksik, kuruluyor...
    call npm install ajv@8 --legacy-peer-deps
)

cd ..

echo.
echo ================================================
echo   Frontend paketleri duzeltildi!
echo ================================================
echo.
echo Simdi BASLA.bat ile sistemi calistirabilirsiniz.
pause
