# Akdo Mobil

Akdo için Flutter ile geliştirilmiş, Android, iOS ve web'de çalışan müşteri ve
personel uygulaması. Müşteriler menüyü görüntüleyebilir, hesaplarıyla giriş
yapabilir, üye bakiyesiyle sipariş verebilir ve sipariş/bildirimlerini takip
edebilir. Yönetici, şef ve garson girişleri de uygulamada bulunur.

> Uygulama arayüzü **LunaSoft ürünüdür**. Uygulamanın çalışması için Akdo API
> sunucusu ayrıca kurulmalı ve erişilebilir olmalıdır.

## Özellikler

- Müşteri, yönetici, AkdoŞef ve AkdoGarson giriş akışları
- Müşteri üyeliği, kullanıcı adıyla giriş, profil ve bakiye
- Menü, ürün arama ve kategori filtreleme
- Masadan sipariş, sipariş takibi ve sipariş geçmişi
- Üyeler için uygulama içi bildirimler ve yöneticiler için duyuru gönderimi
- Şef sipariş kuyruğu, durum güncelleme ve iptal edilen üye bakiyesi siparişleri
  için iade
- Türkiye il ve ilçe listeleriyle şube kaydı
- Siyah-beyaz Material 3 teması ve `ThemeExtension` tasarım token'ları

## Gereksinimler

- Flutter SDK ve Dart SDK (sürüm aralığı için [`pubspec.yaml`](./pubspec.yaml)
  dosyasındaki `environment` alanına bakın)
- Android Studio/Xcode gibi hedef platformun araçları
- Akdo API/backend sunucusuna erişim

## Kurulum

1. Depoyu klonlayıp Flutter bağımlılıklarını yükleyin:

   ```bash
   git clone <depo-adresi>
   cd akdomobil
   flutter pub get
   ```

2. Akdo backend'ini ayrıca kurun ve çalıştırın. Backend kurulumu, ortam
   değişkenleri ve veritabanı yönergeleri backend deposundaki README'de yer alır.

3. API adresini hedef ortama göre ayarlayın. `API_BASE_URL` değerine sonda `/`
   olmadan, uygulamanın erişebileceği backend adresini verin:

   ```bash
   flutter run --dart-define=API_BASE_URL=https://api.ornek.com
   ```

   Gerçek Android cihazda `localhost` cihazın kendisini gösterir; geliştirme
   bilgisayarının LAN adresini kullanın. Üretimde HTTPS kullanın. Web sürümü API
   çağrılarını aynı origin'e gönderir.

## Çalıştırma

```bash
# Bağlı cihaz veya varsayılan hedef
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000

# Chrome
flutter run -d chrome

# Testler
flutter test

# Kod analizi
flutter analyze

# Web derlemesi
flutter build web
```

### Yerel web proxy'si

Depoda bulunan `web_proxy.py`, yerel geliştirme sırasında web uygulamasının API
isteklerini `http://localhost:3000` adresindeki backend'e aktarır ve `build/web`
içeriğini `http://localhost:8081` üzerinden sunar. Backend'i ve ardından Flutter
web derlemesini başlattıktan sonra proxy'yi proje klasöründe çalıştırın:

```bash
python web_proxy.py
```

Bu proxy geliştirme içindir; internete açık üretim sunucusu olarak kullanmayın.
Farklı bir bilgisayarda kullanacaksanız `web_proxy.py` içindeki backend adresi ve
`AKDO_ROOT` yolunu kendi yerel kurulumunuza göre düzenleyin. Üretimde web
dosyalarını HTTPS kullanan bir web sunucusunda yayınlayın ve API erişimini
sunucu/proxy yapılandırmasıyla sağlayın.

## API yapılandırması

Uygulama API isteklerini `lib/main.dart` içindeki `ApiClient` üzerinden yapar.
Derleme sırasında `--dart-define=API_BASE_URL=...` ile verilen değer Android ve
iOS gibi web dışı hedeflerde API adresi olarak kullanılır. Değer verilmediğinde
uygulamanın yerel geliştirme varsayılanı kullanılır. Web hedefi aynı origin'i
kullanır.

## Bildirimler ve KVKK

- Uygulama içi bildirimler desteklenir. Telefon push bildirimleri için henüz
  Firebase Cloud Messaging yapılandırması eklenmemiştir.
- Üyelik ekranındaki KVKK metni bilgilendirme özetidir; işletmeye ait tam
  aydınlatma metninin yerini tutmaz. Yayına almadan önce veri sorumlusu ve iletişim
  bilgileri dahil gerekli yasal bilgiler tamamlanmalı ve metin hukuk danışmanına
  inceletilmelidir.

## Güvenlik

- API anahtarlarını, parolaları, oturum sırlarını veya özel anahtarları kaynak
  koda ya da GitHub'a eklemeyin.
- Backend ortam değişkenlerini backend sunucusunda güvenli biçimde yapılandırın.
- Üretim ortamında HTTPS kullanın; geliştirme proxy'sini üretimde açmayın.

## Sürüm

Uygulama sürümü `pubspec.yaml` dosyasındaki `version` alanından yönetilir. Şu anki
sürüm: **1.0.0+1**.
