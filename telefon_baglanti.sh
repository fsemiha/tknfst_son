#!/bin/bash

# Telefon Bağlantı Yardımcısı - Siber Macera
# Telefonunuzda oyunu açmak için gerekli bilgileri gösterir

clear
echo "📱 SİBER MACERA - TELEFON BAĞLANTI YARDIMCISI"
echo "=============================================="
echo ""

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Server durumunu kontrol et
if systemctl is-active --quiet httpd; then
    echo -e "${GREEN}✅ Apache Web Server çalışıyor${NC}"
else
    echo -e "${RED}❌ Apache Web Server çalışmıyor!${NC}"
    echo "Çözüm: sudo systemctl start httpd"
    exit 1
fi

# IP adresini al
SERVER_IP=$(hostname -I | awk '{print $1}')
GAME_URL="http://${SERVER_IP}/index.html"

echo -e "${BLUE}🌐 Server Bilgileri:${NC}"
echo "IP Adresi: $SERVER_IP"
echo "Oyun URL'si: $GAME_URL"
echo ""

# QR kod göster
echo -e "${YELLOW}📱 TELEFON BAĞLANTISI İÇİN:${NC}"
echo ""
echo "1️⃣  QR KODU OKUTUN:"
echo "==================="
qrencode -t UTF8 "$GAME_URL"
echo ""

echo "2️⃣  MANUEL GİRİŞ:"
echo "================"
echo "Telefon browser'ınızda şu adresi açın:"
echo -e "${GREEN}$GAME_URL${NC}"
echo ""

echo "3️⃣  PWA KURULUMU:"
echo "================="
echo "• Android: Chrome menü → 'Ana ekrana ekle'"
echo "• iPhone: Safari paylaş → 'Ana Ekrana Ekle'"
echo ""

# Network test
echo -e "${BLUE}🔧 BAĞLANTI TESTİ:${NC}"
if curl -s --connect-timeout 3 "$GAME_URL" > /dev/null; then
    echo -e "${GREEN}✅ Oyun erişilebilir durumda${NC}"
else
    echo -e "${RED}❌ Oyuna erişim sorunu var${NC}"
    echo "Firewall kontrolü: sudo firewall-cmd --list-all"
fi
echo ""

# QR kod dosyası oluştur
echo -e "${YELLOW}💾 QR KODU KAYDETME:${NC}"
QR_FILE="/tmp/siber_macera_qr.png"
qrencode -t PNG -s 8 -o "$QR_FILE" "$GAME_URL"
echo "QR kod dosyası: $QR_FILE"
echo "WhatsApp/Telegram ile paylaşabilirsiniz"
echo ""

# WiFi bilgileri
echo -e "${BLUE}📶 WİFİ AĞINIZ:${NC}"
WIFI_SSID=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d\: -f2)
if [ ! -z "$WIFI_SSID" ]; then
    echo "Bağlı olduğunuz ağ: $WIFI_SSID"
    echo -e "${YELLOW}⚠️ Telefonunuzu da aynı WiFi ağına bağlayın!${NC}"
else
    echo "WiFi ağ bilgisi alınamadı"
fi
echo ""

# Port kontrolü
echo -e "${BLUE}🔧 PORT DURUMU:${NC}"
if netstat -tlnp | grep -q ":80 "; then
    echo -e "${GREEN}✅ Port 80 açık${NC}"
else
    echo -e "${RED}❌ Port 80 kapalı${NC}"
    echo "Çözüm: sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload"
fi
echo ""

# Troubleshooting
echo -e "${YELLOW}🛠️ SORUN GİDERME:${NC}"
echo ""
echo "❌ Telefonda sayfa açılmıyor:"
echo "   → Aynı WiFi ağında olduğunuzdan emin olun"
echo "   → IP adresini doğru girdiğinizi kontrol edin"
echo "   → Firewall ayarlarını kontrol edin"
echo ""
echo "❌ PWA kurulamıyor:"
echo "   → HTTPS gerekebilir (production için)"
echo "   → Modern browser kullanın (Chrome/Safari)"
echo "   → JavaScript'in etkin olduğunu kontrol edin"
echo ""
echo "❌ Oyun yavaş çalışıyor:"
echo "   → WiFi sinyalini güçlendirin"
echo "   → Diğer uygulamaları kapatın"
echo "   → Browser cache'ini temizleyin"
echo ""

# Son kontroller
echo -e "${GREEN}🎮 OYUNA BAŞLAMAYA HAZIR!${NC}"
echo ""
echo "Telefon kurulum adımları:"
echo "1. Telefonunuzu '$WIFI_SSID' ağına bağlayın"
echo "2. QR kodu okutun veya URL'yi manuel girin"
echo "3. PWA olarak kurun (opsiyonel)"
echo "4. Oyunun keyfini çıkarın!"
echo ""
echo -e "${BLUE}📞 Hızlı erişim için bu komutu tekrar çalıştırın:${NC}"
echo "./telefon_baglanti.sh"
