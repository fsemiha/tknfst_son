#!/bin/bash

# Siber Macera - RedHat Otomatik Kurulum Scripti
# Honor Pad 9 Tablet Kiosk Mode için optimize edilmiştir

set -e

echo "🚀 Siber Macera RedHat Kurulum Scripti Başlatılıyor..."
echo "================================================="

# Renkli output için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Root kontrolü
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Bu script root yetkileriyle çalıştırılmalıdır!${NC}"
   echo "Kullanım: sudo ./setup_redhat.sh"
   exit 1
fi

# Sistem bilgilerini al
echo -e "${BLUE}📊 Sistem Bilgileri:${NC}"
echo "OS: $(cat /etc/redhat-release)"
echo "IP: $(hostname -I | awk '{print $1}')"
echo "Hostname: $(hostname)"
echo ""

# Paket yöneticisini güncelle
echo -e "${YELLOW}📦 Paket veritabanı güncelleniyor...${NC}"
dnf update -y > /dev/null 2>&1

# Gerekli paketleri kur
echo -e "${YELLOW}⚙️ Gerekli paketler kuruluyor...${NC}"
dnf install -y httpd firewalld qrencode curl wget unzip > /dev/null 2>&1

# Apache'yi etkinleştir
echo -e "${YELLOW}🌐 Apache HTTP Server yapılandırılıyor...${NC}"
systemctl start httpd
systemctl enable httpd

# Firewall ayarları
echo -e "${YELLOW}🔥 Firewall yapılandırılıyor...${NC}"
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=http > /dev/null 2>&1
firewall-cmd --permanent --add-service=https > /dev/null 2>&1
firewall-cmd --permanent --add-port=8080/tcp > /dev/null 2>&1
firewall-cmd --reload > /dev/null 2>&1

# Web dizinini temizle
echo -e "${YELLOW}📁 Web dizini hazırlanıyor...${NC}"
rm -rf /var/www/html/*

# Oyun dosyalarını kopyala (mevcut dizinden)
GAME_DIR="$(dirname "$0")"
if [ -f "$GAME_DIR/index.html" ]; then
    echo -e "${GREEN}🎮 Oyun dosyaları kopyalanıyor...${NC}"
    cp -r "$GAME_DIR"/* /var/www/html/
    
    # Gereksiz dosyaları temizle
    rm -f /var/www/html/setup_redhat.sh
    rm -f /var/www/html/REDHAT_KURULUM_REHBERI.md
    rm -rf /var/www/html/android_wrapper
else
    echo -e "${RED}❌ Oyun dosyaları bulunamadı!${NC}"
    echo "Script'i oyun dosyalarının bulunduğu dizinde çalıştırın."
    exit 1
fi

# Dosya izinlerini ayarla
echo -e "${YELLOW}🔐 Dosya izinleri ayarlanıyor...${NC}"
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/

# SELinux ayarları
echo -e "${YELLOW}🛡️ SELinux yapılandırılıyor...${NC}"
setsebool -P httpd_can_network_connect 1 > /dev/null 2>&1
restorecon -R /var/www/html/ > /dev/null 2>&1

# Apache konfigürasyonu optimize et
echo -e "${YELLOW}⚡ Apache performans optimizasyonu...${NC}"
cat > /etc/httpd/conf.d/siber-macera.conf << 'EOF'
# Siber Macera Optimizasyon Ayarları

# Compression
LoadModule deflate_module modules/mod_deflate.so
<Directory "/var/www/html">
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png|svg)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI \
        \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</Directory>

# Cache headers for static files
<IfModule mod_expires.c>
    ExpiresActive On
    <Directory "/var/www/html">
        ExpiresByType text/css "access plus 1 year"
        ExpiresByType application/javascript "access plus 1 year"
        ExpiresByType image/svg+xml "access plus 1 year"
        ExpiresByType font/woff2 "access plus 1 year"
        ExpiresByType font/otf "access plus 1 year"
    </Directory>
</IfModule>

# Security headers
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set X-Frame-Options SAMEORIGIN
</IfModule>

# Custom error pages
ErrorDocument 404 /index.html
ErrorDocument 500 /index.html
EOF

# Apache'yi yeniden başlat
systemctl restart httpd

# IP adresini al
SERVER_IP=$(hostname -I | awk '{print $1}')
GAME_URL="http://${SERVER_IP}/index.html"

# QR kod oluştur
echo -e "${YELLOW}📱 QR kod oluşturuluyor...${NC}"
qrencode -t UTF8 "$GAME_URL" > /tmp/qr_code.txt
qrencode -t PNG -s 8 -o /var/www/html/qr_code.png "$GAME_URL"

# Firebase konfigürasyon kontrolü
echo -e "${YELLOW}🔥 Firebase konfigürasyonu kontrol ediliyor...${NC}"
if grep -q "YOUR_API_KEY" /var/www/html/firebase-config.js 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Firebase konfigürasyonu henüz yapılmamış!${NC}"
    echo "firebase-config.js dosyasını düzenleyerek Firebase bilgilerinizi girin."
fi

# Test bağlantısı
echo -e "${YELLOW}🧪 Bağlantı testi yapılıyor...${NC}"
if curl -s -o /dev/null -w "%{http_code}" "$GAME_URL" | grep -q "200"; then
    echo -e "${GREEN}✅ Web server başarıyla çalışıyor!${NC}"
else
    echo -e "${RED}❌ Web server bağlantı hatası!${NC}"
fi

# Sonuç raporu
echo ""
echo -e "${GREEN}🎉 KURULUM TAMAMLANDI! 🎉${NC}"
echo "================================="
echo ""
echo -e "${BLUE}📱 Tablet Bağlantı Bilgileri:${NC}"
echo "URL: $GAME_URL"
echo "IP Adresi: $SERVER_IP"
echo ""
echo -e "${BLUE}📱 QR Kod:${NC}"
cat /tmp/qr_code.txt
echo ""
echo -e "${BLUE}🔧 Yönetim Komutları:${NC}"
echo "Apache durumu: systemctl status httpd"
echo "Apache yeniden başlat: systemctl restart httpd"
echo "Log izleme: tail -f /var/log/httpd/access_log"
echo "Firewall durumu: firewall-cmd --list-all"
echo ""
echo -e "${BLUE}📋 Tablet Kurulum Adımları:${NC}"
echo "1. Honor Pad 9'u aynı WiFi ağına bağlayın"
echo "2. QR kodu okutun veya URL'yi manuel girin: $GAME_URL"
echo "3. Chrome/Edge'de 'Add to Home Screen' ile PWA olarak kurun"
echo "4. Kiosk mode için KIOSK_MODE_REHBERI.md dosyasını inceleyin"
echo ""
echo -e "${BLUE}🔥 Firebase Ayarları:${NC}"
echo "firebase-config.js dosyasını düzenleyerek Firebase ayarlarınızı yapın"
echo "Firebase Console: https://console.firebase.google.com"
echo ""
echo -e "${YELLOW}⚠️ Güvenlik Notu:${NC}"
echo "Üretim ortamında HTTPS kullanmayı unutmayın!"
echo "SSL sertifikası için: certbot --apache"
echo ""
echo -e "${GREEN}Honor Pad 9 tablet'inizde kiosk mode için hazır! 🚀${NC}"

# QR kod dosyasını temizle
rm -f /tmp/qr_code.txt

exit 0
