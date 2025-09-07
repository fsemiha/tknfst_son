#!/bin/bash

# Siber Macera - Ubuntu/Debian Otomatik Kurulum Scripti
# Honor Pad 9 Tablet Kiosk Mode için optimize edilmiştir
# ÜCRETSIZ ALTERNATIF

set -e

echo "🐧 Siber Macera Ubuntu/Debian Kurulum Scripti"
echo "=============================================="

# Renkli output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Root kontrolü
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Bu script root yetkileriyle çalıştırılmalıdır!${NC}"
   echo "Kullanım: sudo ./setup_ubuntu.sh"
   exit 1
fi

# Sistem bilgileri
echo -e "${BLUE}📊 Sistem Bilgileri:${NC}"
echo "OS: $(lsb_release -d | cut -f2)"
echo "IP: $(hostname -I | awk '{print $1}')"
echo "Hostname: $(hostname)"
echo ""

# Paket veritabanını güncelle
echo -e "${YELLOW}📦 Paket veritabanı güncelleniyor...${NC}"
apt update > /dev/null 2>&1

# Gerekli paketleri kur
echo -e "${YELLOW}⚙️ Gerekli paketler kuruluyor...${NC}"
apt install -y apache2 ufw qrencode curl wget unzip > /dev/null 2>&1

# Apache'yi etkinleştir
echo -e "${YELLOW}🌐 Apache HTTP Server yapılandırılıyor...${NC}"
systemctl start apache2
systemctl enable apache2

# UFW Firewall ayarları
echo -e "${YELLOW}🔥 UFW Firewall yapılandırılıyor...${NC}"
ufw --force enable > /dev/null 2>&1
ufw allow 22/tcp > /dev/null 2>&1  # SSH
ufw allow 80/tcp > /dev/null 2>&1  # HTTP
ufw allow 443/tcp > /dev/null 2>&1 # HTTPS
ufw allow 8080/tcp > /dev/null 2>&1 # Alt port

# Web dizinini temizle
echo -e "${YELLOW}📁 Web dizini hazırlanıyor...${NC}"
rm -rf /var/www/html/*

# Oyun dosyalarını kopyala
GAME_DIR="$(dirname "$0")"
if [ -f "$GAME_DIR/index.html" ]; then
    echo -e "${GREEN}🎮 Oyun dosyaları kopyalanıyor...${NC}"
    cp -r "$GAME_DIR"/* /var/www/html/
    
    # Gereksiz dosyaları temizle
    rm -f /var/www/html/setup_*.sh
    rm -f /var/www/html/*_REHBERI.md
    rm -rf /var/www/html/android_wrapper
else
    echo -e "${RED}❌ Oyun dosyaları bulunamadı!${NC}"
    exit 1
fi

# Dosya izinlerini ayarla
echo -e "${YELLOW}🔐 Dosya izinleri ayarlanıyor...${NC}"
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Apache konfigürasyonu optimize et
echo -e "${YELLOW}⚡ Apache performans optimizasyonu...${NC}"
cat > /etc/apache2/sites-available/siber-macera.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ServerName siber-macera
    
    # Compression
    LoadModule deflate_module modules/mod_deflate.so
    <Directory "/var/www/html">
        SetOutputFilter DEFLATE
        SetEnvIfNoCase Request_URI \
            \.(?:gif|jpe?g|png|svg)$ no-gzip dont-vary
    </Directory>
    
    # Cache headers
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType text/css "access plus 1 year"
        ExpiresByType application/javascript "access plus 1 year"
        ExpiresByType image/svg+xml "access plus 1 year"
        ExpiresByType font/woff2 "access plus 1 year"
    </IfModule>
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options SAMEORIGIN
    
    # Error pages
    ErrorDocument 404 /index.html
    ErrorDocument 500 /index.html
</VirtualHost>
EOF

# Apache modüllerini etkinleştir
a2enmod rewrite > /dev/null 2>&1
a2enmod headers > /dev/null 2>&1
a2enmod expires > /dev/null 2>&1
a2enmod deflate > /dev/null 2>&1

# Site'i etkinleştir
a2ensite siber-macera > /dev/null 2>&1
systemctl restart apache2

# IP ve URL bilgileri
SERVER_IP=$(hostname -I | awk '{print $1}')
GAME_URL="http://${SERVER_IP}/index.html"

# QR kod oluştur
echo -e "${YELLOW}📱 QR kod oluşturuluyor...${NC}"
qrencode -t UTF8 "$GAME_URL" > /tmp/qr_code.txt
qrencode -t PNG -s 8 -o /var/www/html/qr_code.png "$GAME_URL"

# Test bağlantısı
echo -e "${YELLOW}🧪 Bağlantı testi yapılıyor...${NC}"
if curl -s -o /dev/null -w "%{http_code}" "$GAME_URL" | grep -q "200"; then
    echo -e "${GREEN}✅ Web server başarıyla çalışıyor!${NC}"
else
    echo -e "${RED}❌ Web server bağlantı hatası!${NC}"
fi

# Sonuç raporu
echo ""
echo -e "${GREEN}🎉 UBUNTU KURULUM TAMAMLANDI! 🎉${NC}"
echo "====================================="
echo ""
echo -e "${BLUE}💰 Maliyet: TAMAMEN ÜCRETSİZ! 💰${NC}"
echo ""
echo -e "${BLUE}📱 Tablet Bağlantı Bilgileri:${NC}"
echo "URL: $GAME_URL"
echo "IP Adresi: $SERVER_IP"
echo ""
echo -e "${BLUE}📱 QR Kod:${NC}"
cat /tmp/qr_code.txt
echo ""
echo -e "${BLUE}🔧 Ubuntu Yönetim Komutları:${NC}"
echo "Apache durumu: systemctl status apache2"
echo "Apache yeniden başlat: systemctl restart apache2"
echo "Log izleme: tail -f /var/log/apache2/access.log"
echo "Firewall durumu: ufw status"
echo ""
echo -e "${GREEN}Honor Pad 9 için hazır - Ubuntu'da ücretsiz! 🚀${NC}"

rm -f /tmp/qr_code.txt
exit 0
