@echo off
echo ================================================
echo   PLAKA TANIMA SISTEMI - OTOMATIK KURULUM
echo   Evo Teknoloji
echo ================================================
echo.
echo Bu kurulum tum bileşenleri otomatik kontrol edip
echo eksikleri duzeltecektir.
echo.
pause

:: Python ile akıllı kurulumu çalıştır
python smart_install.py

if errorlevel 1 (
    echo.
    echo HATA: Kurulum tamamlanamadi!
    echo Lutfen kurulum_log.txt dosyasini kontrol edin.
    pause
    exit /b 1
)

echo.
echo ================================================
echo   KURULUM TAMAMLANDI!
echo ================================================
echo.
echo Sistemi baslatmak icin BASLA.bat dosyasini calistirin.
echo.
pause
