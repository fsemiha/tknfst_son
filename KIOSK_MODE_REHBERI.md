# 🏪 Honor Pad 9 Kiosk Mode Kurulum Rehberi

Bu rehber, Honor Pad 9 tablet'inde Siber Macera oyununun kiosk modunda sürekli çalışması için gerekli adımları anlatır.

## 📱 Honor Pad 9 Özellikleri
- **Ekran:** 12.1 inch, 2560x1600 çözünürlük
- **İşletim Sistemi:** Android 13 (Magic UI 7.1)
- **Batarya:** 8,300 mAh (yaklaşık 11 saat)
- **Kiosk Modu:** Destekleniyor

## 🔧 Kiosk Mode Kurulumu

### 1. Tablet Hazırlık
```bash
# Geliştirici seçeneklerini aktifleştir
Ayarlar > Tablet hakkında > Derleme numarası (7 kez dokunun)

# USB hata ayıklamayı etkinleştir
Ayarlar > Sistem > Geliştirici seçenekleri > USB hata ayıklama
```

### 2. Güvenlik Ayarları
```bash
# Bilinmeyen kaynaklardan kuruluma izin ver
Ayarlar > Güvenlik > Bilinmeyen kaynaklar

# Ekran kilidi ve şifreyi kaldır (kiosk için)
Ayarlar > Güvenlik > Ekran kilidi > Hiçbiri
```

### 3. Kiosk Modu Aktivasyonu

#### A) Manuel Kiosk Modu
```bash
Ayarlar > Güvenlik > Gelişmiş > Uygulama pinleme
Veya
Ayarlar > Dijital refah > Uygulama pinleme
```

#### B) ADB ile Kiosk Modu (Gelişmiş)
```bash
# ADB bağlantısı kur
adb connect [tablet_ip]:5555

# Kiosk modunu etkinleştir
adb shell dpm set-device-owner com.android.shell/.BugreportWarningActivity

# Uygulamayı kiosk moduna al
adb shell am start -n com.android.chrome/com.google.android.apps.chrome.Main \
  --es "com.android.browser.application_id" "com.android.chrome" \
  --activity-single-top
```

### 4. Browser Konfigürasyonu

#### Chrome Kiosk Modu
1. **Chrome'u varsayılan browser yap**
2. **Kiosk URL'sini ayarla:**
   ```
   file:///android_asset/www/index.html
   # veya
   http://localhost:8080/index.html
   ```

3. **Chrome flags ayarları:**
   ```
   chrome://flags/#enable-webxr
   chrome://flags/#enable-unsafe-webgpu
   ```

#### Edge/Firefox Alternatifi
```javascript
// Oyun URL'si
const kioskURL = "file:///storage/emulated/0/siber-macera/index.html";

// Fullscreen başlat
if (document.documentElement.requestFullscreen) {
    document.documentElement.requestFullscreen();
}
```

## 🔋 Güç Yönetimi

### 1. Sürekli Açık Kalma
```bash
# Ekran kapanma süresini maksimuma çıkar
Ayarlar > Ekran > Ekran zaman aşımı > 30 dakika

# Otomatik parlaklık kapatma
Ayarlar > Ekran > Otomatik parlaklık > KAPALI

# Uyku modunu devre dışı bırak
Ayarlar > Batarya > Güç tasarrufu > KAPALI
```

### 2. Şarj Optimizasyonu
```bash
# Sürekli şarj için USB-C kablosu bağlı bırak
# Güç adaptörü: 5V/2A minimum

# Batarya optimizasyonu
Ayarlar > Batarya > Batarya optimizasyonu > Chrome/Browser > Optimize etme
```

## 🌐 Ağ Konfigürasyonu

### WiFi Ayarları
```bash
# Sabit IP ayarla (opsiyonel)
Ayarlar > WiFi > [Ağ adı] > Gelişmiş > IP ayarları > Statik

# DNS ayarları
Birincil DNS: 8.8.8.8
İkincil DNS: 8.8.4.4
```

### Hotspot Modunda Kullanım
```bash
# Mobil hotspot açma
Ayarlar > Kişisel hotspot > Hotspot'u aç
SSID: SiberMacera_Kiosk
Şifre: [güvenli şifre]
```

## 🔒 Güvenlik ve Kısıtlamalar

### 1. Uygulama Kısıtlamaları
```javascript
// JavaScript'te otomatik kısıtlamalar
- Sağ tık menüsü devre dışı
- F12/DevTools erişimi engellendi
- Metin seçimi engellendi
- Drag & drop devre dışı
- Pinch zoom engellendi
```

### 2. Sistem Kısıtlamaları
```bash
# Ana ekran düğmesi devre dışı (kiosk modunda)
# Bildirim paneli kapalı
# Uygulama geçişi kısıtlı
```

## 📱 APK Wrapper (Opsiyonel)

### Android Studio ile APK Oluşturma
```xml
<!-- AndroidManifest.xml -->
<application android:label="Siber Macera" 
             android:theme="@android:style/Theme.NoTitleBar.Fullscreen"
             android:screenOrientation="landscape">
    
    <activity android:name=".MainActivity"
              android:launchMode="singleTask"
              android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
            <category android:name="android.intent.category.HOME" />
            <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>
    </activity>
</application>
```

### WebView Konfigürasyonu
```java
public class MainActivity extends AppCompatActivity {
    private WebView webView;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Fullscreen ve kiosk ayarları
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        );
        
        webView = new WebView(this);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.setWebChromeClient(new WebChromeClient());
        
        // Oyunu yükle
        webView.loadUrl("file:///android_asset/index.html");
        setContentView(webView);
    }
    
    @Override
    public void onBackPressed() {
        // Back tuşunu devre dışı bırak (kiosk mode)
        // super.onBackPressed();
    }
}
```

## 🚀 Otomatik Başlatma

### 1. Boot Receiver
```xml
<receiver android:name=".BootReceiver">
    <intent-filter android:priority="1000">
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

### 2. Watchdog Servisi
```java
public class KioskWatchdog extends Service {
    // Uygulamanın her zaman açık kalmasını sağla
    // Sistem tarafından kapanırsa yeniden başlat
}
```

## 📊 İzleme ve Yönetim

### Uzaktan Yönetim
```bash
# TeamViewer veya AnyDesk kurarak uzaktan erişim
# Firebase Remote Config ile oyun ayarlarını uzaktan değiştirme
# Analytics ile kullanım istatistikleri toplama
```

### Sistem Durumu Kontrolü
```javascript
// JavaScript ile sistem durumu
setInterval(() => {
    console.log('Kiosk Status:', {
        battery: navigator.getBattery(),
        online: navigator.onLine,
        fullscreen: document.fullscreenElement !== null,
        timestamp: new Date().toISOString()
    });
}, 30000); // Her 30 saniyede kontrol
```

## ⚠️ Önemli Notlar

1. **Güç Kesintisi:** UPS kullanımı önerilir
2. **Internet Bağlantısı:** Skorların kaydı için gerekli
3. **Bakım:** Haftalık uzaktan kontrol önerilir
4. **Güncelleme:** Otomatik güncellemeler kapatılmalı
5. **Yedekleme:** Firebase verileri düzenli yedeklenmeli

## 🔧 Sorun Giderme

### Sık Karşılaşılan Sorunlar
```bash
Problem: Uygulama kapanıyor
Çözüm: Watchdog servisi kurulu olduğundan emin olun

Problem: Ekran kararıyor
Çözüm: Wake Lock aktif olduğunu kontrol edin

Problem: Internet bağlantısı kopuyor
Çözüm: WiFi ayarlarında "Uyku modunda bağlantıyı koru" seçin

Problem: Performans yavaşlıyor
Çözüm: Chrome cache'ini temizleyin, tablet'i yeniden başlatın
```

### Acil Durum Çıkışı
```bash
# Kiosk modundan çıkmak için
1. Tablet'i yeniden başlat
2. Başlangıçta Volume Up + Power tuşlarına bas
3. Recovery mode'a gir
4. Factory reset (son çare)
```

Bu rehber ile Honor Pad 9 tablet'iniz atari makinenizde sürekli açık kalarak güvenilir bir kiosk cihazı olarak çalışacaktır.

