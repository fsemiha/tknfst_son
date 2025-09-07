# 🐧 RedHat Linux - Siber Macera Kurulum Rehberi

Bu rehber, RedHat Enterprise Linux sisteminde Siber Macera oyununun mobil/tablet versiyonunu test etmek için gerekli adımları anlatır.

## 📋 Gereksinimler

- RedHat Enterprise Linux 8/9
- Root veya sudo yetkisi
- İnternet bağlantısı
- Firebase hesabı (skorlar için)

## 🔧 Web Server Kurulumu

### 1. Apache HTTP Server Kurulumu

```bash
# Paket yöneticisini güncelle
sudo dnf update -y

# Apache web server kurulumu
sudo dnf install httpd -y

# Apache'yi başlat ve etkinleştir
sudo systemctl start httpd
sudo systemctl enable httpd

# Firewall ayarları
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Apache durumunu kontrol et
sudo systemctl status httpd
```

### 2. Nginx Alternatifi (Daha Hafif)

```bash
# Nginx kurulumu
sudo dnf install nginx -y

# Nginx'i başlat ve etkinleştir
sudo systemctl start nginx
sudo systemctl enable nginx

# Firewall ayarları
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 📁 Oyun Dosyalarını Yerleştirme

### Apache için:
```bash
# Web dizinine git
cd /var/www/html

# Oyun dosyalarını kopyala (zip'ten çıkardıktan sonra)
sudo cp -r /path/to/Oyun\ 2/* /var/www/html/

# Dosya izinlerini ayarla
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

# SELinux ayarları (gerekirse)
sudo setsebool -P httpd_can_network_connect 1
sudo restorecon -R /var/www/html/
```

### Nginx için:
```bash
# Web dizinine git
cd /usr/share/nginx/html

# Oyun dosyalarını kopyala
sudo cp -r /path/to/Oyun\ 2/* /usr/share/nginx/html/

# Dosya izinlerini ayarla
sudo chown -R nginx:nginx /usr/share/nginx/html/
sudo chmod -R 755 /usr/share/nginx/html/
```

## 🌐 Network Konfigürasyonu

### IP Adresini Öğrenme
```bash
# Sistem IP adresini öğren
ip addr show

# Dış IP adresini öğren (gerekirse)
curl ifconfig.me

# Hostname'i kontrol et
hostname -I
```

### Port Ayarları
```bash
# Farklı port kullanımı (8080 örneği)
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Apache için port değişikli (opsiyonel)
sudo vim /etc/httpd/conf/httpd.conf
# Listen 8080 ekle

# Apache'yi yeniden başlat
sudo systemctl restart httpd
```

## 📱 Mobil Test Ortamı

### 1. QR Code Oluşturma
```bash
# QR code generator kurulumu
sudo dnf install qrencode -y

# Oyun URL'si için QR kod oluştur
qrencode -t UTF8 "http://YOUR_IP_ADDRESS/index.html"

# PNG formatında QR kod
qrencode -t PNG -o siber_macera_qr.png "http://YOUR_IP_ADDRESS/index.html"
```

### 2. HTTPS Sertifikası (PWA için gerekli)
```bash
# Let's Encrypt kurulumu
sudo dnf install certbot python3-certbot-apache -y

# SSL sertifikası al (domain gerekli)
sudo certbot --apache -d yourdomain.com

# Self-signed sertifika (test için)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/selfsigned.key \
    -out /etc/ssl/certs/selfsigned.crt

# Apache SSL konfigürasyonu
sudo vim /etc/httpd/conf.d/ssl.conf
```

## 🔥 Firebase Konfigürasyonu

### 1. Firebase Config Düzenleme
```bash
# Firebase config dosyasını düzenle
sudo vim /var/www/html/firebase-config.js

# Aşağıdaki bilgileri güncelle:
const FIREBASE_CONFIG = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    databaseURL: "https://YOUR_PROJECT-default-rtdb.firebaseio.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
};
```

### 2. Firebase Rules Güncelleme
```bash
# Firebase rules dosyasını kontrol et
cat /var/www/html/firebase-security-rules.json

# Firebase Console'da rules'ları güncelle
# https://console.firebase.google.com
```

## 📊 Monitoring ve Logs

### Apache Logs
```bash
# Error log
sudo tail -f /var/log/httpd/error_log

# Access log
sudo tail -f /var/log/httpd/access_log

# Log rotation ayarları
sudo vim /etc/logrotate.d/httpd
```

### Nginx Logs
```bash
# Error log
sudo tail -f /var/log/nginx/error.log

# Access log
sudo tail -f /var/log/nginx/access.log
```

### Sistem Resource Monitoring
```bash
# Sistem durumu
htop
iotop
netstat -tlnp

# Disk kullanımı
df -h
du -sh /var/www/html/*

# Memory kullanımı
free -h
```

## 🔧 Performance Optimizasyonu

### Apache Optimizasyonu
```bash
# Apache config düzenle
sudo vim /etc/httpd/conf/httpd.conf

# Aşağıdaki ayarları ekle/düzenle:
```

```apache
# Compression
LoadModule deflate_module modules/mod_deflate.so
<Location />
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI \
        \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</Location>

# Cache headers
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# Security headers
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
Header always set Referrer-Policy "strict-origin-when-cross-origin"
```

### Nginx Optimizasyonu
```bash
# Nginx config düzenle
sudo vim /etc/nginx/nginx.conf
```

```nginx
http {
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        image/svg+xml;
    
    # Browser caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header Referrer-Policy "strict-origin-when-cross-origin";
}
```

## 🧪 Test Senaryoları

### 1. Masaüstü Test
```bash
# Firefox ile test
firefox http://localhost/index.html

# Chrome ile test (snap kurulumlu ise)
google-chrome http://localhost/index.html

# Curl ile HTTP response test
curl -I http://localhost/index.html
```

### 2. Mobil Simülasyon
```bash
# Firefox Developer Tools ile mobil simülasyon
# F12 > Responsive Design Mode

# Chrome DevTools ile tablet simülasyon
# F12 > Toggle Device Toolbar > iPad/Android Tablet
```

### 3. Network Test
```bash
# Same network'teki cihazlardan test
# Tablet/telefonu aynı WiFi'ye bağla
# http://YOUR_SERVER_IP/index.html adresine git

# Network speed test
iperf3 -s # Server modunda çalıştır
# Tablet'ten: iperf3 -c SERVER_IP
```

## 🔐 Güvenlik Ayarları

### SELinux Konfigürasyonu
```bash
# SELinux durumunu kontrol et
getenforce

# Web server için izinler
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_can_network_relay 1

# Dosya context'lerini ayarla
sudo semanage fcontext -a -t httpd_exec_t "/var/www/html/.*"
sudo restorecon -R /var/www/html/
```

### Firewall İleri Seviye
```bash
# Sadece belirli IP'lerden erişim
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="http" accept'

# Rate limiting
sudo firewall-cmd --permanent --add-rich-rule='rule service name="http" accept limit value="10/m"'

# Firewall'u yeniden yükle
sudo firewall-cmd --reload
```

## 📱 Tablet Bağlantı Rehberi

### 1. Aynı Network'e Bağlanma
1. **RedHat server IP'sini öğren:** `ip addr show`
2. **Tablet'i aynı WiFi'ye bağla**
3. **Tablet browser'ında aç:** `http://SERVER_IP/index.html`

### 2. QR Code ile Kolay Erişim
```bash
# QR kod oluştur ve göster
qrencode -t UTF8 "http://$(hostname -I | awk '{print $1}')/index.html"

# QR kod dosyasını oluştur
qrencode -t PNG -s 8 -o oyun_qr.png "http://$(hostname -I | awk '{print $1}')/index.html"

# QR kodu tablet kamerasıyla okut
```

### 3. Kiosk Mode Aktivasyonu
1. **Tablet'te oyunu aç**
2. **PWA olarak install et** (Chrome menüsünden "Add to Home Screen")
3. **Kiosk app'ini çalıştır**
4. **Fullscreen mode otomatik aktif olacak**

## ⚠️ Sorun Giderme

### Yaygın Problemler
```bash
# Apache başlamıyor
sudo systemctl status httpd
sudo journalctl -u httpd

# Port zaten kullanımda
sudo netstat -tlnp | grep :80
sudo lsof -i :80

# Permission denied
sudo chmod -R 755 /var/www/html/
sudo chown -R apache:apache /var/www/html/

# SELinux engelliyorsa
sudo setenforce 0  # Geçici olarak kapat
# /etc/selinux/config dosyasında SELINUX=disabled yap (kalıcı)

# Firebase bağlantı sorunu
# Browser console'da hata mesajlarını kontrol et
# Network tab'ında Firebase requests'leri izle
```

### Performance Sorunları
```bash
# Memory yetersizse
free -h
sudo systemctl restart httpd

# Disk doluysa
df -h
sudo journalctl --vacuum-time=7d

# Network yavaşsa
ping google.com
traceroute google.com
```

Bu rehber ile RedHat sisteminizde oyunu başarıyla çalıştırabilir ve Honor Pad 9 tablet'inizde test edebilirsiniz. Herhangi bir sorunla karşılaştığınızda log dosyalarını kontrol ederek çözüm bulabilirsiniz.
