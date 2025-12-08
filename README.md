# Borç Defteri - Flutter Uygulaması

Modern ve kullanıcı dostu bir borç takibi ve stok yönetimi uygulaması.

## 🎯 Özellikler

### 📝 Borç Defteri
- **Mekan Yönetimi**: Farklı mekanlar (örn: Barış Köyü) oluşturun
- **Kişi Takibi**: Her mekanda birden fazla kişi ekleyin
- **Borç/Ödeme Kaydı**: 
  - Borç ekleme ve takibi
  - Ödeme kaydetme (borçtan düşer)
  - Otomatik toplam borç hesaplama
  - Tarih ve açıklama ile detaylı kayıt
- **Güvenli Silme**: Önemli işlemler için çift onay sistemi

### 📦 Stok Kontrol
- **Fotoğraflı Ürün Yönetimi**: Her ürün için fotoğraf ekleme
- **Hızlı Stok Güncelleme**: + ve - butonları ile kolay stok değişikliği
- **Stok Geçmişi**: Tüm stok hareketlerinin tarihli kaydı
- **Detaylı Görünüm**: Ürün detayları ve geçmiş işlemler

## 🛠️ Teknolojiler

- **Flutter 3.x** - Cross-platform UI framework
- **Dart** - Programlama dili
- **SQLite** - Yerel veritabanı (sqflite)
- **Image Picker** - Fotoğraf seçme
- **Material 3** - Modern UI tasarım sistemi

## 📱 Kurulum

### Gereksinimler
1. Flutter SDK (3.0 veya üzeri)
2. Android Studio veya VS Code
3. Android SDK (API 21+)

### Adımlar

1. **Flutter SDK Kurulumu**
   ```bash
   # Flutter'ı indirin: https://flutter.dev/docs/get-started/install
   # PATH'e ekleyin
   ```

2. **Projeyi Hazırlayın**
   ```bash
   cd borc_defteri
   flutter pub get
   ```

3. **Uygulamayı Çalıştırın**
   ```bash
   # Bağlı cihazları kontrol edin
   flutter devices
   
   # Uygulamayı başlatın
   flutter run
   ```

## 📂 Proje Yapısı

```
borc_defteri/
├── lib/
│   ├── main.dart                    # Ana giriş noktası
│   ├── models/                      # Veri modelleri
│   │   ├── location.dart
│   │   ├── person.dart
│   │   ├── transaction.dart
│   │   ├── product.dart
│   │   └── stock_history.dart
│   ├── database/                    # Veritabanı katmanı
│   │   └── database_helper.dart
│   ├── screens/                     # UI ekranları
│   │   ├── home_screen.dart
│   │   ├── locations_screen.dart
│   │   ├── persons_screen.dart
│   │   ├── transactions_screen.dart
│   │   ├── products_screen.dart
│   │   └── product_detail_screen.dart
│   └── widgets/                     # Yeniden kullanılabilir widget'lar
│       ├── confirmation_dialog.dart
│       └── custom_card.dart
├── android/                         # Android platformu
└── pubspec.yaml                     # Bağımlılıklar
```

## 🎨 Özellikler ve Kullanım

### Borç Defteri Kullanımı

1. **Mekan Ekleme**
   - Ana ekranda sağ alttaki ➕ butonuna tıklayın
   - Mekan adını girin (örn: "Barış Köyü")

2. **Kişi Ekleme**
   - Bir mekana tıklayın
   - ➕ butonuna basıp kişi adını girin (örn: "Ali Duru")

3. **Borç/Ödeme Ekleme**
   - Bir kişiye tıklayın
   - "Borç Ekle" veya "Ödeme Ekle" butonuna basın
   - Tutar ve açıklama girin
   - Onaylayın

4. **Silme İşlemleri**
   - Herhangi bir kartı uzun basın (long press)
   - İki kez onaylayın

### Stok Kontrol Kullanımı

1. **Ürün Ekleme**
   - Stok Kontrol sekmesine geçin
   - ➕ butonuna basın
   - Fotoğraf seçin
   - Ürün adı ve başlangıç adedini girin

2. **Stok Güncelleme**
   - Ürün kartındaki ➕ veya ➖ butonlarına basın
   - Değişikliği onaylayın

3. **Detay Görüntüleme**
   - Ürün kartına tıklayın
   - Tüm stok geçmişini görün

## 🎭 UI/UX Özellikleri

- ✨ Modern Material 3 tasarımı
- 🌓 Otomatik karanlık/aydınlık tema desteği
- 🎨 Renkli ve gradient kartlar
- ⚡ Hızlı ve akıcı animasyonlar
- 📱 Responsive tasarım
- 🇹🇷 Tam Türkçe dil desteği
- ⏱️ Akıllı tarih formatlama (Bugün, Dün, X gün önce)

## 📊 Veritabanı Şeması

### Tablolar
- **locations** - Mekanlar
- **persons** - Kişiler (mekan ile ilişkili)
- **transactions** - Borç/ödeme kayıtları (kişi ile ilişkili)
- **products** - Ürünler
- **stock_histories** - Stok değişiklik kayıtları

## 🔐 İzinler

Uygulama şu izinleri kullanır:
- **Camera** - Ürün fotoğrafı çekmek için
- **Storage** - Fotoğraf seçmek ve kaydetmek için

## 📝 Notlar

- Tüm veriler cihazda yerel olarak saklanır (SQLite)
- İnternet bağlantısı gerektirmez
- Veriler cihazda kalır, bulut senkronizasyonu yoktur

## 🚀 Geliştirme

### Debug Modu
```bash
flutter run
```

### Release APK Oluşturma
```bash
flutter build apk --release
```

### Analiz ve Test
```bash
flutter analyze
flutter test
```

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

## 👨‍💻 Geliştirici

Flutter ile ❤️ ile geliştirildi.
