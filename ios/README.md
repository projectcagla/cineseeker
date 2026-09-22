# CineSeeker iOS — sunucusuz V1

Swift 6, SwiftUI ve SwiftData ile iPhone/iPad uygulaması; minimum iOS 17. Cloudflare, D1, Resend, alan adı veya CineSeeker hesabı gerekmez. Katalog internet üzerinden doğrudan TMDB'den alınır; izleme listesi, puanlar ve tercihler cihazda saklanır.

## Başlatmak için tek katalog ayarı

1. Masaüstü tarayıcıda TMDB hesabınızın **Settings → API** bölümünden **API Read Access Token** alın. Kısa v3 API Key yerine uzun okuma token'ını kullanın: [TMDB uygulama kimlik doğrulaması](https://developer.themoviedb.org/docs/authentication-application).
2. Depo kökünde `cp ios/Config/Config.example.xcconfig ios/Config/Config.xcconfig` çalıştırın. Dosya zaten varsa üzerine yazmadan düzenleyin.
3. `Config.xcconfig` içinde `TMDB_READ_TOKEN =` satırına token'ı girin. Bu dosya Git'e gönderilmez. Token'ı sohbete veya kaynak dosyalara yazmayın.
4. `ios/CineSeeker.xcodeproj` dosyasını Xcode'da açın, `CineSeeker` şemasını ve bir iPhone simülatörünü seçip Run'a basın.

Simülatörde Apple üyeliği veya Team ID gerekmez. TMDB token'ı yoksa uygulama derlenir ve yerel kayıtları açar; katalog için açık bir yapılandırma durumu gösterir. Uygulamada sahte film kataloğu bulunmaz.

**Mobil istemci sınırı:** Token derleme sırasında uygulama paketine aktarılır; `.xcconfig` veya Keychain, dağıtılan bir uygulamadaki ortak erişim anahtarını tamamen gizleyemez. V1 yalnızca TMDB uygulama okuma token'ını kullanır; özel sunucu, e-posta veya Apple anahtarları uygulamaya girmez. V2 proxy ile bu anahtarı sunucu tarafına taşıyabiliriz. TMDB kullanım/lisans koşulları geçerlidir.

## V1 kapsamı

| Özellik | Davranış |
|---|---|
| Keşfet | Türkiye'de abonelik/kiralama/satın alma seçeneği bulunan film ve diziler |
| Platformlarım | Seçili servislerde abonelik kapsamında erişilebilen içerikler |
| Yeni Çıkanlar | Son 180 günde çıkmış, Türkiye'de yayın seçeneği olan içerikler; platforma yeni eklenme tarihi değildir |
| Arama | 300 ms beklemeli arama, film/dizi ve tür filtreleri, yerel geçmiş |
| Ayrıntılar | Özet, türler, oyuncular, süre/sezon, Türkiye yayın seçenekleri |
| İzleme listesi | `want`, `watching`, `watched`; 1–10 puan veya boş; kart/liste görünümü; metin arama ve sıralama |
| Çevrimdışı | Kaydedilen liste ve tercihler açılır; daha önce önbelleğe alınmamış afişler için nötr görsel kullanılır |
| Ayarlar | Platform seçimi, JSON paylaşımı, arama geçmişini ve tüm yerel kişisel verileri silme |
| Atıflar | Resmi TMDB logosu/açıklaması ve JustWatch atfı |

Giriş, kayıt, şifre sıfırlama, cihazlar arası eşitleme ve sunucuyla platform ekleme takibi **V2'ye ertelendi**. Uygulama V1'de bu uçlara istek göndermez. Depodaki web/Cloudflare kodu gelecekteki sürüm için korunmuştur; iOS V1'i kullanmak için yayınlamayın.

Uygulamayı silmek yerel kayıtları kaldırabilir. JSON dışa aktarımı bir veri kopyası verir; V1 otomatik bulut eşitlemesi veya JSON geri yükleme akışı içermez. iOS cihaz yedekleri kullanıcının sistem ayarlarına tabidir.

## Mimari

- `Models` ve `Domain`: film/dizi kimlikleri, katalog protokolü, izleme durumları.
- `Data/LiveCatalogRepository`: doğrudan TMDB; TR filtreleri; platform aramalarında en fazla beş eşzamanlı istek; sıralama ve sayfalama korunur.
- `Core/Network`: actor tabanlı URLSession, Bearer başlığı, sabit TMDB adresi, başka kök adrese yönlendirmeyi reddetme, sınırlı 429 tekrar denemesi, URLCache.
- `Core/Storage`: SwiftData, yerel kayıtlar ve metadata. Önceki geliştirme sürümünden `PendingMutation` şeması yalnızca veritabanı uyumluluğu için korunur; V1 kuyruk oluşturmaz veya göndermez.
- `Features`: Observation/MVVM, Türkçe arayüz, Dynamic Type, erişilebilirlik etiketleri ve Reduce Motion uyumu.

Yeni Swift dosyası eklenirse `python3 ios/scripts/generate_project.py` ile paylaşılan şema ve proje dosyasını yeniden oluşturun. Yerel ayarlar `Config.xcconfig` içinde olmalıdır.

## Doğrulama

```sh
cd ios
xcodebuild test -project CineSeeker.xcodeproj -scheme CineSeeker \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' CODE_SIGNING_ALLOWED=NO

xcodebuild archive -project CineSeeker.xcodeproj -scheme CineSeeker \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/CineSeeker.xcarchive CODE_SIGNING_ALLOWED=NO
```

İkinci komutun imzasız arşivi TestFlight'a yüklenemez. Birim testlerine ek olarak iPhone/iPad temel gezinme ve büyük yazı kontrolleri paylaşılan şemaya dahildir. Son yerel sonuçlar ve canlı test sınırları [VALIDATION.md](VALIDATION.md) içindedir. Ağ yanıtı örnekleri yalnızca test hedefinde kullanılır; uygulama canlı TMDB istemcisidir.

## Xcode Cloud ile otomatik TestFlight

Xcode Cloud ürünü Apple hesabına ve `projectcagla/cineseeker` GitHub deposuna bağlandı. Uygulama kaydı: `6814588419`; Bundle ID: `com.projectcagla.cineseeker`; takım: `9PF6U63MV3`.

Hedef iş akışı **CineSeeker TestFlight**: `feat/native-ios` dalındaki değişiklik → Xcode 27 (27A266a) → zorunlu iOS 27 testleri → Release arşivi → dahili TestFlight grubu. Bu dal dışındaki değişiklikler bu iş akışını tetiklemez. TestFlight yeni bir uygulama derlemesi dağıtır; kurulu uygulamanın kodu anında değişmez. Test cihazında TestFlight otomatik güncellemeleri açılabilir.

`ios/ci_scripts/ci_post_clone.sh`, Cloud Environment bölümündeki **Secret** türündeki `TMDB_READ_TOKEN` değerini Git dışında kalan `Config/Config.xcconfig` dosyasına aktarır. Anahtarı loglara yazmaz; eksik/bozuk değerle derlemeyi durdurur. Xcode Cloud imzalamayı Apple hesabı üzerinden yönetir; bu yol için Fastlane match deposu veya App Store Connect API anahtarı gerekmez.

Kurulumun canlı durumu [VALIDATION.md](VALIDATION.md) içindedir. Cloud iş akışı ayarları Apple’da tutulur; depodaki `xcshareddata/xcodecloud/manifest.json` ürün bağlantısını taşır. Yalnızca bu dosyayı kopyalamak başka hesapta iş akışı oluşturmaz.

Apple belgeleri: [özel derleme betikleri](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts), [TestFlight dağıtımı](https://developer.apple.com/documentation/xcode/distributing-your-xcode-cloud-builds-through-testflight).

## Alternatif: elle Fastlane dağıtımı

1. Apple Developer üyeliğini ve sözleşmeleri tamamlayın. Identifiers bölümünde `com.projectcagla.cineseeker` Bundle ID'sini kaydedin; App Store Connect'te aynı kimlikle yeni iOS uygulaması oluşturun. Benzersizlik Apple tarafından doğrulanır.
2. App Store Connect → Users and Access → Integrations bölümünden sertifika/profil yönetimine yetkili bir **Team API Key** oluşturun. `.p8` dosyasını depoya koymayın. Team ID, Apple Developer üyelik bilgilerindedir.
3. Fastlane `match` için yalnızca imzalama varlıkları tutulacak özel bir Git deposu hazırlayın. İçerik `MATCH_PASSWORD` ile şifrelenir. CI yalnızca mevcut sertifikaları okur.
4. Ruby 3.3 / Bundler ortamında `cd ios && bundle install`; aşağıdaki değişkenlerle bir kez `bundle exec fastlane ios prepare_signing` çalıştırın.
5. GitHub'da `testflight` environment'ını oluşturup aşağıdaki değerleri ekleyin.

| Tür | Ad | İçerik |
|---|---|---|
| Secret | `TMDB_READ_TOKEN` | TMDB API Read Access Token |
| Secret | `APP_STORE_CONNECT_API_KEY_ID` | Team API Key ID |
| Secret | `APP_STORE_CONNECT_ISSUER_ID` | Issuer UUID |
| Secret | `APP_STORE_CONNECT_API_KEY_KEY` | `.p8` içeriğinin base64 hali |
| Variable | `APPLE_TEAM_ID` | 10 karakterli Apple üyelik Team ID |
| Variable | `APP_IDENTIFIER` | `com.projectcagla.cineseeker` veya kayıtlı kimliğiniz |
| Secret | `MATCH_GIT_URL` | Özel sertifika deposunun HTTPS Git adresi |
| Secret | `MATCH_PASSWORD` | Sertifika deposunun şifreleme parolası |
| Secret | `MATCH_GIT_BASIC_AUTHORIZATION` | Sertifika deposuna erişen `kullanici:token` çiftinin base64 hali |

**`API_BASE_URL`, Cloudflare ve Resend secrets V1 için gerekli değildir.**

`bundle exec fastlane ios beta`: TMDB token'ını doğrular, imzalama varlıklarını alır, son TestFlight build numarasını artırır, Release `.ipa` üretir ve yükler. Token geçersiz veya eksikse yüklemeye devam etmez.

GitHub Actions → **iOS validation and TestFlight** → Run workflow → `upload_testflight: true`. Push/PR sadece test çalıştırır. macos-14/Xcode 16.2 uyumluluk testleri; macos-26 üzerindeki güncel SDK imzalı yükleme için kullanılır. macos-14 çalıştırıcısının kullanım ömrünü takip edin.

[Apple SDK şartları](https://developer.apple.com/news/upcoming-requirements/) · [Fastlane API key](https://docs.fastlane.tools/app-store-connect-api/) · [Fastlane match](https://docs.fastlane.tools/actions/match/)

## Gizlilik ve yayın

V1 e-posta, ad veya kullanıcı hesabı toplamaz. Liste/puan/geçmiş cihazdadır; arama metni ve platform/tür filtreleri TMDB'ye iletilir. Bu davranış uygulama içindeki gizlilik metninde açıklanır. TMDB'nin kendi veri saklama uygulamalarını da hesaba katarak App Store gizlilik beyanlarını tamamlayın. App Store için gerekli herkese açık gizlilik/destek sayfası statik bir sayfada barındırılabilir; uygulama sunucusu gerektirmez.

TestFlight için Apple hesabı ve imzalama yine gereklidir. Gerçek TMDB token'ıyla katalog, arama, platform listesi ve ayrıntıları cihazda kontrol edin. Yayından önce fiziksel cihaz, erişilebilirlik ve iOS 17 runtime kontrollerini tamamlayın.
