
# 🌍 Earthquake Tracking App

A Flutter-based mobile application that allows users to track earthquakes in Turkey in real time.  
The app fetches and combines data from **Kandilli Observatory** and **AFAD**, providing up-to-date and reliable earthquake information.

---

## 📸 Screenshots

<div align="center">
  <img src="screenshots/deprem1.jpeg" alt="Earthquake List - Home Screen" width="250"/>
  <img src="screenshots/deprem2.jpeg" alt="Earthquake Cards" width="250"/>
  <br/>
  <img src="screenshots/deprem3.jpeg" alt="Map View" width="250"/>
  <img src="screenshots/deprem4.jpeg" alt="Settings and Filters" width="250"/>
</div>

---

## 📱 Features

### 🔄 Real-Time Data Tracking
- Dual data source support (Kandilli Observatory & AFAD)
- Automatic data refresh every 1 minute (configurable)
- Automatic refresh when the app is opened or resumed
- Manual refresh with pull-to-refresh
- Visual indicator for newly detected earthquakes

### 📊 Filtering and Sorting
- Magnitude-based filtering (0.0 – 8.0)
- Sorting options:
  - By magnitude (ascending / descending)
  - By date (newest / oldest)
  - By depth (deep to shallow / shallow to deep)
- Instant filtering without reloading data

### 🗺️ Map View
- Interactive map powered by OpenStreetMap
- Color-coded markers based on magnitude:
  - 🔴 Red: ≥ 5.0
  - 🟠 Orange: ≥ 4.0
  - 🟡 Yellow: ≥ 3.0
  - 🟢 Green: < 3.0
- Tap markers to view detailed earthquake information

### 🔔 Notification System
- Smart notifications based on magnitude thresholds
- Customizable notification threshold (3.0 – 7.0)
- Configurable check interval (1–10 minutes)
- Lock screen notification support
- Duplicate notification prevention

### 🎨 Modern UI / UX
- Material Design 3
- Dynamic color coding based on magnitude
- Responsive layout for different screen sizes
- Smooth scrolling with custom scroll physics
- Fluid animations and transitions

### 📋 Detailed Earthquake Information
Each earthquake card displays:
- Magnitude (with color and icon)
- Location
- Depth (km)
- Date and time
- Nearest city
- Data source badge (Kandilli / AFAD)

---

## 🛠️ Technologies

### Frontend
- Flutter – Cross-platform mobile development framework
- Dart – Programming language

### State Management
- Provider – Centralized state management pattern

### API & Data
- HTTP – REST API integration
- JSON parsing and data modeling
- SharedPreferences – Local storage for user settings

### Map
- flutter_map – OpenStreetMap integration
- latlong2 – Coordinate operations

### Notifications
- flutter_local_notifications – Local notification system

### Others
- intl – Date and time formatting

---

## 📁 Project Structure

```text
lib/
├── main.dart
├── models/
├── providers/
├── screens/
├── services/
└── widgets/
````

---

## 🚀 Installation

### Requirements

* Flutter SDK (3.9.2 or higher)
* Dart SDK
* Android Studio / VS Code
* Android SDK or iOS SDK

### Steps

```bash
git clone https://github.com/EsraGumus7/deprem-uygulamasi.git
cd deprem-uygulamasi
flutter pub get
flutter run
```

---

## 🎯 Technical Highlights

* Provider-based state management
* RESTful API integration with proper error handling
* Dual earthquake data source support
* Threshold-based smart notification system
* Modular and maintainable project architecture

---

## 👤 Developer

Esra Gümüş
GitHub: [@EsraGumus7](https://github.com/EsraGumus7)














🌍 Earthquake Tracking App

A Flutter-based mobile application that allows users to track earthquakes in Turkey in real time.
The app fetches and combines data from Kandilli Observatory and AFAD, providing up-to-date and reliable earthquake information.

📸 Screenshots
<div align="center"> <img src="screenshots/deprem1.jpeg" alt="Earthquake List - Home Screen" width="250"/> <img src="screenshots/deprem2.jpeg" alt="Earthquake Cards" width="250"/> <br/> <img src="screenshots/deprem3.jpeg" alt="Map View" width="250"/> <img src="screenshots/deprem4.jpeg" alt="Settings and Filters" width="250"/> </div>
📱 Features
🔄 Real-Time Data Tracking

Dual Data Source Support: Simultaneously tracks data from Kandilli Observatory and AFAD

Automatic Updates: Periodic data refresh every 1 minute (configurable)

App Lifecycle Refresh: Automatically updates data when the app is opened or brought to the foreground

Manual Refresh: Pull-to-refresh support for instant updates

New Earthquake Indicator: Visual indication when a new earthquake is detected

📊 Filtering and Sorting

Magnitude Filter: Filter earthquakes by minimum magnitude (0.0 – 8.0)

Sorting Options:

By magnitude (Ascending / Descending)

By date (Newest / Oldest)

By depth (Deep to Shallow / Shallow to Deep)

Dynamic Filtering: Filters are applied instantly without reloading

🗺️ Map View

Interactive Map: Visualizes earthquakes on a map using OpenStreetMap

Color-Coded Markers based on magnitude:

🔴 Red: ≥ 5.0

🟠 Orange: ≥ 4.0

🟡 Yellow: ≥ 3.0

🟢 Green: < 3.0

Marker Details: Tap markers to view detailed earthquake information

🔔 Notification System

Smart Notifications: Automatically notifies users based on configurable magnitude thresholds

Custom Threshold: Adjustable notification threshold between 3.0 – 7.0

Check Interval: Configurable control interval (1–10 minutes)

Lock Screen Support: Notifications are shown even when the device is locked

Duplicate Prevention: The same earthquake is never notified twice

🎨 Modern UI/UX

Material Design 3

Dynamic Color Coding based on earthquake magnitude

Responsive Layout for different screen sizes

Smooth Scrolling with customized scroll physics

Fluid Animations and transitions

📋 Detailed Earthquake Information

Each earthquake card displays:

Magnitude (with color and icon)

Location

Depth (km)

Date and time

Nearest city

Source badge (Kandilli / AFAD)

🛠️ Technologies
Frontend

Flutter – Cross-platform mobile development framework

Dart – Programming language

State Management

Provider – Centralized state management pattern

API & Data

HTTP – REST API integration

JSON Parsing – Data modeling and parsing

SharedPreferences – Local storage for user settings

Map

flutter_map – OpenStreetMap integration

latlong2 – Coordinate operations

Notifications

flutter_local_notifications – Local notification system

Others

intl – Date and time formatting

📁 Project Structure
lib/
├── main.dart
├── models/
├── providers/
├── screens/
├── services/
└── widgets/

🚀 Installation
Requirements

Flutter SDK (3.9.2 or higher)

Dart SDK

Android Studio / VS Code

Android SDK or iOS SDK

Steps
git clone https://github.com/EsraGumus7/deprem-uygulamasi.git
cd deprem-uygulamasi
flutter pub get
flutter run

🎯 Technical Highlights

Provider-based state management

RESTful API integration with error handling

Dual earthquake data source support

Threshold-based smart notification system

Modular and maintainable project architecture

👤 Developer

Esra Gümüş
GitHub: @EsraGumus7








# 🌍 Deprem Takip Uygulaması

Türkiye'deki depremleri gerçek zamanlı takip eden, Flutter ile geliştirilmiş mobil uygulama. Kandilli Rasathanesi ve AFAD verilerini kullanarak kullanıcılara anlık deprem bilgileri sunar.

## 📸 Ekran Görüntüleri

<div align="center">
  <img src="screenshots/deprem1.jpeg" alt="Deprem Listesi - Ana Ekran" width="250"/>
  <img src="screenshots/deprem2.jpeg" alt="Deprem Kartları" width="250"/>
  <br/>
  <img src="screenshots/deprem3.jpeg" alt="Harita Görünümü" width="250"/>
  <img src="screenshots/deprem4.jpeg" alt="Ayarlar ve Filtreleme" width="250"/>
</div>

## 📱 Özellikler

### 🔄 Gerçek Zamanlı Veri Takibi
- **Çift Kaynak Desteği**: Kandilli Rasathanesi ve AFAD verilerini aynı anda takip eder
- **Otomatik Güncelleme**: Periyodik kontrol sistemi ile her 1 dakikada bir otomatik veri güncellemesi (ayarlanabilir)
- **Uygulama Açılışında Güncelleme**: Uygulama açıldığında veya ön plana geldiğinde otomatik veri yenileme
- **Manuel Yenileme**: Pull-to-refresh özelliği ile anında veri güncelleme
- **Yeni Deprem Bildirimi**: Yeni depremler eklendiğinde görsel bildirim gösterimi

### 📊 Filtreleme ve Sıralama
- **Büyüklük Filtresi**: Minimum büyüklük değerine göre filtreleme (0.0 - 8.0)
- **Sıralama Seçenekleri**:
  - Büyüklüğe göre (Artan/Azalan)
  - Tarihe göre (En Yeni/En Eski)
  - Derinliğe göre (Derinden Sığa/Sığdan Derine)
- **Dinamik Filtreleme**: Filtreler anlık olarak uygulanır

### 🗺️ Harita Görünümü
- **İnteraktif Harita**: OpenStreetMap entegrasyonu ile tüm depremlerin harita üzerinde görselleştirilmesi
- **Renkli Marker'lar**: Deprem büyüklüğüne göre renkli işaretleme sistemi
  - 🔴 Kırmızı: ≥5.0 büyüklükte
  - 🟠 Turuncu: ≥4.0 büyüklükte
  - 🟡 Sarı: ≥3.0 büyüklükte
  - 🟢 Yeşil: <3.0 büyüklükte
- **Marker Detayları**: Marker'lara tıklanarak deprem detaylarını görüntüleme

### 🔔 Bildirim Sistemi
- **Akıllı Bildirimler**: Ayarlanabilir eşik değerine göre otomatik bildirim gönderimi
- **Özelleştirilebilir Eşik**: 3.0 - 7.0 arası bildirim eşiği ayarlama
- **Kontrol Aralığı**: 1-10 dakika arası kontrol periyodu ayarlama
- **Kilitli Ekran Desteği**: Uygulama açıkken kilitli ekranda da bildirim gösterimi
- **Tekrar Önleme**: Aynı deprem tekrar bildirilmez

### 🎨 Modern UI/UX
- **Material Design 3**: Modern ve kullanıcı dostu arayüz
- **Renkli Büyüklük Gösterimi**: Deprem büyüklüğüne göre dinamik renk kodlaması
- **Responsive Tasarım**: Farklı ekran boyutlarına uyumlu
- **Yavaş Kaydırma**: Özelleştirilmiş scroll physics ile rahat kaydırma deneyimi
- **Smooth Animations**: Akıcı geçişler ve animasyonlar

### 📋 Detaylı Deprem Bilgileri
Her deprem kartında gösterilen bilgiler:
- Büyüklük (renkli ve ikonlu)
- Lokasyon bilgisi
- Derinlik (km)
- Tarih ve saat
- En yakın şehir bilgisi
- Kaynak badge (Kandilli/AFAD)

## 🛠️ Teknolojiler

### Frontend
- **Flutter**: Cross-platform mobil uygulama geliştirme framework'ü
- **Dart**: Programlama dili

### State Management
- **Provider**: State management pattern ile merkezi durum yönetimi

### API & Veri
- **HTTP**: REST API entegrasyonu
- **JSON Parsing**: Veri modelleme ve parse işlemleri
- **SharedPreferences**: Yerel veri saklama (ayarlar)

### Harita
- **flutter_map**: OpenStreetMap entegrasyonu
- **latlong2**: Koordinat işlemleri

### Bildirimler
- **flutter_local_notifications**: Lokal bildirim sistemi

### Diğer
- **intl**: Tarih ve saat formatlama

## 📁 Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/                     # Veri modelleri
│   ├── deprem.dart
│   ├── deprem_kaynagi.dart
│   └── siralama_tipi.dart
├── providers/                  # State management
│   └── deprem_provider.dart
├── screens/                    # Ekranlar
│   ├── deprem_listesi_screen.dart
│   ├── harita_screen.dart
│   └── ayarlar_screen.dart
├── services/                  # Servisler
│   ├── deprem_service.dart
│   └── bildirim_service.dart
└── widgets/                   # Widget'lar
    └── deprem_card.dart
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.9.2 veya üzeri)
- Dart SDK
- Android Studio / VS Code
- Android SDK veya iOS SDK

### Adımlar

1. **Repository'yi klonlayın**
   ```bash
   git clone https://github.com/EsraGumus7/deprem-uygulamasi.git
   cd deprem-uygulamasi
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 📦 Kullanılan Paketler

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  provider: ^6.1.1
  intl: ^0.19.0
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  flutter_local_notifications: ^17.2.3
  shared_preferences: ^2.3.3
```

## 🎯 Öne Çıkan Teknik Özellikler

### State Management
- Provider pattern ile merkezi state yönetimi
- ChangeNotifier ile reactive UI güncellemeleri
- Consumer widget'ları ile optimize edilmiş rebuild'ler

### API Entegrasyonu
- RESTful API ile asenkron veri çekme
- Error handling ve timeout yönetimi
- JSON parsing ve model mapping
- Çift kaynak (Kandilli & AFAD) desteği

### Bildirim Sistemi
- Local notifications ile push bildirimleri
- Periyodik kontrol ile otomatik bildirim
- Eşik tabanlı akıllı bildirim sistemi
- Tekrar önleme mekanizması

### Kullanıcı Deneyimi
- Otomatik güncelleme sistemi
- Pull-to-refresh özelliği
- Filtreleme ve sıralama
- Harita görünümü
- Ayarlanabilir parametreler

## 📊 Proje İstatistikleri

- **Toplam Satır**: ~1500+ satır kod
- **Dosya Sayısı**: 15+ kaynak dosya
- **Ekran Sayısı**: 3 ana ekran
- **Servis Sayısı**: 2 servis katmanı
- **Model Sayısı**: 3 veri modeli

## 🔧 Geliştirme Özellikleri

- **Debug Logging**: Terminal'de detaylı log sistemi
- **Error Handling**: Kapsamlı hata yönetimi
- **Code Organization**: Modüler ve sürdürülebilir kod yapısı
- **Clean Code**: Okunabilir ve bakımı kolay kod

## 📝 Lisans

Bu proje eğitim ve CV amaçlı geliştirilmiştir.

## 👤 Geliştirici

**Esra Gümüş**

- GitHub: [@EsraGumus7](https://github.com/EsraGumus7)

## 🙏 Teşekkürler

- Kandilli Rasathanesi ve AFAD için açık API desteği
- Flutter topluluğu
- OpenStreetMap harita servisi

---

⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!
