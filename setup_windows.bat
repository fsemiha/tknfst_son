@echo off
chcp 65001 >nul
title Siber Macera - Windows Kurulum

echo.
echo 🚀 SİBER MACERA - WINDOWS KURULUM SCRİPTİ
echo ==========================================
echo.

REM Admin kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Bu script Admin yetkisiyle çalıştırılmalıdır!
    echo Sağ tık → "Yönetici olarak çalıştır"
    pause
    exit /b 1
)

echo ✅ Admin yetkileri doğrulandı
echo.

REM Sistem bilgileri
echo 📊 Sistem Bilgileri:
echo OS: %OS%
echo Bilgisayar: %COMPUTERNAME%
echo Kullanıcı: %USERNAME%
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
    set IP=%%a
    goto :found
)
:found
echo IP Adresi:%IP%
echo.

REM XAMPP kontrolü
echo 🔍 XAMPP kontrolü yapılıyor...
if exist "C:\xampp\xampp-control.exe" (
    echo ✅ XAMPP zaten kurulu
    goto :copy_files
) else (
    echo ❌ XAMPP bulunamadı
    echo.
    echo 📦 XAMPP kurulumu gerekli:
    echo 1. https://www.apachefriends.org/tr/index.html adresine gidin
    echo 2. "Windows için XAMPP" indirin
    echo 3. Kurulum yapın (Apache + MySQL seçili)
    echo 4. Bu scripti tekrar çalıştırın
    echo.
    pause
    exit /b 1
)

:copy_files
REM htdocs'u temizle
echo 🗑️ Eski dosyalar temizleniyor...
if exist "C:\xampp\htdocs\*" (
    del /Q "C:\xampp\htdocs\*.*" 2>nul
    for /d %%d in ("C:\xampp\htdocs\*") do rmdir /s /q "%%d" 2>nul
)

REM Oyun dosyalarını kopyala
echo 📁 Oyun dosyaları kopyalanıyor...
set SOURCE_DIR=%~dp0
if exist "%SOURCE_DIR%index.html" (
    xcopy "%SOURCE_DIR%*.*" "C:\xampp\htdocs\" /E /H /Y >nul
    echo ✅ Dosyalar başarıyla kopyalandı
) else (
    echo ❌ Oyun dosyaları bulunamadı!
    echo Bu scripti oyun dosyalarının bulunduğu klasörde çalıştırın
    pause
    exit /b 1
)

REM Gereksiz dosyaları temizle
echo 🧹 Gereksiz dosyalar temizleniyor...
del "C:\xampp\htdocs\setup_*.bat" 2>nul
del "C:\xampp\htdocs\setup_*.sh" 2>nul
del "C:\xampp\htdocs\*_REHBERI.md" 2>nul
rmdir /s /q "C:\xampp\htdocs\android_wrapper" 2>nul

REM XAMPP servislerini başlat
echo 🌐 Apache web server başlatılıyor...
tasklist /FI "IMAGENAME eq httpd.exe" 2>nul | find /I /N "httpd.exe" >nul
if "%ERRORLEVEL%"=="0" (
    echo ✅ Apache zaten çalışıyor
) else (
    start "" "C:\xampp\xampp-control.exe"
    echo 📋 XAMPP Control Panel açıldı
    echo ⚠️  Apache ve MySQL'i START butonlarıyla başlatın
    echo.
)

REM IP adresini al
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4" ^| findstr /V "127.0.0.1"') do (
    set REAL_IP=%%a
    set REAL_IP=!REAL_IP: =!
    goto :ip_found
)
:ip_found

REM Test URL'leri
set LOCAL_URL=http://localhost/index.html
set NETWORK_URL=http://%REAL_IP%/index.html

REM QR kod oluştur (PowerShell ile)
echo 📱 QR kod oluşturuluyor...
powershell -Command "Add-Type -AssemblyName System.Drawing; Add-Type -AssemblyName System.Windows.Forms; $qr = 'http://%REAL_IP%/index.html'; Write-Host 'QR Link: ' $qr"

echo.
echo 🎉 KURULUM TAMAMLANDI! 🎉
echo ========================
echo.
echo 🖥️  Yerel Test: %LOCAL_URL%
echo 📱 Tablet Erişimi: %NETWORK_URL%
echo 💻 IP Adresi: %REAL_IP%
echo.
echo 📋 Sonraki Adımlar:
echo 1. XAMPP Control Panel'de Apache'yi başlatın
echo 2. Browser'da http://localhost/index.html açın
echo 3. Honor Pad 9'u aynı WiFi ağına bağlayın
echo 4. Tablet'te http://%REAL_IP%/index.html açın
echo.
echo 🔧 XAMPP Yönetimi:
echo - Control Panel: C:\xampp\xampp-control.exe
echo - Web dosyaları: C:\xampp\htdocs\
echo - Apache durdur/başlat: XAMPP Control Panel
echo.
echo ⚠️  Firebase ayarları:
echo firebase-config.js dosyasını düzenleyerek Firebase bilgilerinizi girin
echo.
echo 📱 Honor Pad 9 Kiosk Mode:
echo KIOSK_MODE_REHBERI.md dosyasını inceleyin
echo.

REM Test bağlantısı
echo 🧪 Bağlantı testi yapılıyor...
ping -n 1 localhost >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Network bağlantısı başarılı
) else (
    echo ❌ Network bağlantı sorunu
)

echo.
echo 🚀 Honor Pad 9 tablet için hazır!
echo.
pause
