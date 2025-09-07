# 🪟 Windows Kurulum Rehberi - Siber Macera

## 🚀 **SEÇENEK 1: XAMPP (EN KOLAY)**

### Adım 1: XAMPP İndirin
```
1. https://www.apachefriends.org/tr/index.html adresine gidin
2. "Windows için XAMPP" indirin
3. Kurulum dosyasını çalıştırın
```

### Adım 2: XAMPP Kurulumu
```
✅ Apache seçili olsun
✅ MySQL seçili olsun (skorlar için)
❌ Diğerleri opsiyonel

Kurulum yeri: C:\xampp (varsayılan)
```

### Adım 3: Oyun Dosyalarını Kopyalayın
```
1. C:\xampp\htdocs klasörünü açın
2. İçindeki tüm dosyaları silin
3. "Oyun 2" klasöründeki tüm dosyaları buraya kopyalayın
```

### Adım 4: XAMPP'ı Başlatın
```
1. XAMPP Control Panel'i açın
2. Apache'yi START yapın
3. MySQL'i START yapın (yeşil olacak)
```

### Adım 5: Test Edin
```
Browser'da açın: http://localhost/index.html
Oyun çalışıyor mu kontrol edin!
```

### Adım 6: Honor Pad 9 Bağlantısı
```
1. Windows IP adresinizi öğrenin: ipconfig
2. Honor Pad 9'u aynı WiFi'ye bağlayın
3. Tablet'te açın: http://[WINDOWS_IP]/index.html
```

---

## 🐧 **SEÇENEK 2: WSL2 + Ubuntu (PROFESSIONAL)**

### Adım 1: WSL2 Kurulumu
```powershell
# PowerShell'i Admin olarak açın
wsl --install
wsl --set-default-version 2
```

### Adım 2: Ubuntu Kurulumu
```powershell
wsl --install -d Ubuntu-22.04
```

### Adım 3: Ubuntu'da Kurulum
```bash
# WSL Ubuntu'da çalıştırın:
sudo apt update
sudo apt install -y apache2 qrencode curl

# Oyun dosyalarını kopyalayın
sudo cp -r /mnt/c/Users/fatma/Downloads/teknofestoyun_web/teknofestoyun_v18/"Oyun 2"/* /var/www/html/

# Apache'yi başlatın
sudo systemctl start apache2
```

---

## 🌐 **SEÇENEK 3: VirtualBox + Ubuntu (TAM PROFESYONEL)**

### Adım 1: VirtualBox Kurulumu
```
1. https://www.virtualbox.org/wiki/Downloads
2. Windows installer indirin ve kurun
```

### Adım 2: Ubuntu ISO İndirin
```
1. https://ubuntu.com/download/server
2. Ubuntu Server 22.04 LTS indirin
```

### Adım 3: VM Oluşturun
```
VirtualBox'ta:
- New VM → Ubuntu 64-bit
- RAM: 2GB minimum
- Disk: 20GB minimum
- Network: Bridged Adapter
```

---

## 🎯 **HANGİSİNİ SEÇECEĞİZ?**

### **Test İçin: XAMPP (ÖNERİLEN)**
✅ **5 dakikada kurulur**
✅ **Windows'ta kolay**
✅ **Hemen test edebilirsiniz**
✅ **Honor Pad 9 ile çalışır**

### **Production İçin: WSL2 + Ubuntu**  
✅ **Linux komutları kullanılır**
✅ **Daha profesyonel**
✅ **Gerçek server benzeri**

### **Tam Ayrı Server: VirtualBox**
✅ **İzole ortam**
✅ **Gerçek production test**
✅ **En güvenli**

---

## 🚀 **HEMEN BAŞLAYALIM - XAMPP İLE**

Size XAMPP ile başlamayı öneriyorum. En kolay ve hızlı yöntem!

### Hemen şimdi yapın:
1. **XAMPP indirin:** https://www.apachefriends.org/tr/index.html
2. **Kurun** (Apache + MySQL seçili)
3. **Oyun dosyalarını** C:\xampp\htdocs'a kopyalayın
4. **Apache'yi başlatın**
5. **Test edin:** http://localhost/index.html

**Hangi seçeneği tercih ediyorsunuz?**
