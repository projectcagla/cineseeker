# CineSeeker iOS

Native Swift 6 / SwiftUI uygulaması; iPhone ve iPad, iOS 17+. Xcode projesi depoda hazırdır: **`ios/CineSeeker.xcodeproj`**. CocoaPods, Carthage veya üçüncü taraf iOS çalışma zamanı bağımlılığı yoktur.

## İlk kez açma

1. `ios/CineSeeker.xcodeproj` dosyasını Xcode 16.2+ ile açın. Güncel TestFlight yüklemesi için Xcode 26+ kullanın.
2. `CineSeeker` şemasını ve bir iPhone simülatörünü seçin, Run düğmesine basın. Simülatör için Apple üyeliği gerekmez.
3. Canlı sunucu hazır olduğunda `cp ios/Config/Config.example.xcconfig ios/Config/Config.xcconfig` çalıştırın. HTTPS kök adresini ve Apple Team ID'yi bu dosyaya girin.
4. `API_BASE_URL` yalnızca kök adres olmalıdır (ör. `https://cineseeker.example.com`); `/api` eklemeyin. xcconfig içindeki `//` yorum kuralı nedeniyle örnekteki `https:$(SLASH)/...` sözdizimini koruyun.

Sunucu ayarı yoksa uygulama bağlantı durumunu açıklar; sahte film veya sahte hesap oluşturmaz. Daha önce kaydedilen yerel liste çevrimdışıyken açılır. İlk kurulumda film ve güncel platform kataloğu için sunucu gereklidir.

## Henüz alan adı veya Bundle ID yoksa

- Önerilen Bundle ID: **`com.projectcagla.cineseeker`**. Bu bir alan adı satın alma zorunluluğu getirmez. Apple Developer → Certificates, Identifiers & Profiles → Identifiers → App IDs bölümünde aynı değeri kaydedin. Benzersizlik Apple tarafından doğrulanır; başka biri kullanıyorsa size ait başka bir kimlik seçin.
- App Store Connect → My Apps → + → New App: platform iOS, isim CineSeeker, ana dil Türkçe, az önce oluşturulan Bundle ID, size özel bir SKU.
- Team ID, Apple Developer → Membership Details bölümündeki 10 karakterli değerdir. Bu bilgi ve uygulama kaydı olmadan imzalı TestFlight dağıtımı yapılamaz.
- Canlı sunucu için [backend kurulum adımlarını](BACKEND.md) izleyin. Başlangıçta Cloudflare'ın verdiği `workers.dev` adresini kullanabilirsiniz; özel alan adı şart değildir.

## Mimari ve veri davranışı

- `Models` / `Domain`: `movie` ve `tv` için ayrı anahtarlar, katalog protokolü, durum ve kullanıcı modelleri.
- `Data` / `Core/Network`: actor tabanlı ağ katmanı; TMDB anahtarı yalnızca sunucuda. Mobil uygulama yalnızca `/api/mobile/catalog` üzerinden erişir. Oturum cookie'leri Keychain'de; farklı kök adrese yönlendirme reddedilir.
- `Core/Storage`: SwiftData ile liste, puan, abonelikler, son aramalar, platform kataloğu ve kalıcı bekleyen işlemler. Kaydetme önce cihazda yapılır; giriş varsa sıralı, tekrar gönderilebilir işlemler sunucuya uygulanır. Ön planda 30 saniyede bir ve değişiklik sonrası tekrar denenir.
- Misafir kayıtları ve her hesabın kayıtları ayrıdır. Misafir listesi otomatik olarak bir hesaba aktarılmaz. Hesap değişiminde eski hesabın kuyruk işlemleri yeni hesaba yazılamaz; sunucu beklenen kullanıcı kimliğini kontrol eder.
- Çakışma politikası: bekleyen cihaz düzenlemeleri gönderildikten sonra sunucu durumu alınır; en son sunucuya ulaşan işlem kazanır. İstek sırasında oluşan yerel değişiklikler ezilmez.
- Görseller `URLCache` ile bellekte/diskte tutulur. Daha önce indirilmemiş veya önbellekten çıkarılmış afişler çevrimdışı durumdayken nötr görselle gösterilir; film adı/durum/puan korunur.
- `Features`: `@Observable` view model'ler, SwiftUI navigation, Türkçe hata/boş durumları, Dynamic Type, VoiceOver etiketleri ve Reduce Motion uyumu.
- Yeni eklenenler: D1 `availability_snapshot` içindeki son 30 günlük gözlemler; son 48 saatte tekrar görülen kayıtlar. Vizyon tarihi dijital platforma eklenme tarihi olarak kullanılmaz. Tarama popüler film/dizilerden örneklem alır; eksiksiz katalog veya kesin prömiyer tarihi garantisi vermez. İlk tarama başlangıç kataloğudur.
- Platformlar TMDB Türkiye listesinden alınır. Yeniden adlandırılan servisler güncel adlarıyla görünür; artık aktif olmayan eski marka adları sabit olarak dayatılmaz.
- Puanlar 1–10 veya boş; durumlar `want`, `watching`, `watched`.

## Testler ve derleme

```sh
# Depo kökünde sunucu kontrolleri
npm ci
npx tsc --noEmit
npm run lint
npm test

# iOS; cihaz adı kurulu simülatöre göre değişebilir
cd ios
xcodebuild test -project CineSeeker.xcodeproj -scheme CineSeeker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO

# İmzasız cihaz arşivi, dağıtım için kullanılamaz
xcodebuild archive -project CineSeeker.xcodeproj -scheme CineSeeker \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/CineSeeker.xcarchive CODE_SIGNING_ALLOWED=NO
```

Yeni Swift dosyası eklenirse `python3 ios/scripts/generate_project.py` ile projeyi deterministik olarak yeniden oluşturabilirsiniz. Şema paylaşılmıştır. Yerel özelleştirmeler `Config.xcconfig` içinde tutulmalıdır; proje üretimi elle yapılan proje ayarlarını yeniden yazar.

## TestFlight: bir kez yapılacak hazırlık

1. Ücretli Apple Developer üyeliğini, sözleşmeleri ve App Store Connect uygulama kaydını tamamlayın. Bundle ID ve Team ID'yi ayarlayın.
2. App Store Connect → Users and Access → Integrations → App Store Connect API bölümünden provisioning erişimi olan **Team API Key** oluşturun. Sertifika yönetimi için uygun Admin yetkisini verin. `.p8` dosyasını güvenli saklayın, depoya eklemeyin.
3. Sertifika ve özel anahtarı her CI çalışmasında yeniden üretmemek için yalnızca imzalama için kullanılacak özel bir Git deposu oluşturun. Fastlane `match` bu depoyu `MATCH_PASSWORD` ile şifreler. CI erişim bilgilerini sır olarak tanımlayın.
4. Ruby 3.3 ve Bundler kurulu ortamda `cd ios && bundle install` çalıştırın. Aşağıdaki ortam değişkenlerini güvenli şekilde tanımladıktan sonra **bir kez** `bundle exec fastlane ios prepare_signing` çalıştırın. Bu komut API key ile sertifika/profil oluşturur, şifreli özel depoda saklar. CI yalnızca hazır imzalama varlıklarını okur.
5. GitHub → Settings → Environments → `testflight` ortamını oluşturun. Dağıtım secrets/variables değerlerini buraya ekleyin. Kişisel API anahtarı provisioning erişimi vermediğinden Team Key kullanın.

| Tür | Ad | İçerik |
|---|---|---|
| Secret | `APP_STORE_CONNECT_API_KEY_ID` | Team API Key ID |
| Secret | `APP_STORE_CONNECT_ISSUER_ID` | Issuer UUID |
| Secret | `APP_STORE_CONNECT_API_KEY_KEY` | `.p8` dosyasının base64 içeriği; ham PEM değil |
| Variable | `APPLE_TEAM_ID` | Apple üyelik Team ID |
| Variable | `APP_IDENTIFIER` | `com.projectcagla.cineseeker` veya kaydettiğiniz değer |
| Variable | `API_BASE_URL` | Yayınlanmış HTTPS sunucu kökü |
| Secret | `MATCH_GIT_URL` | Özel sertifika deposunun HTTPS Git adresi |
| Secret | `MATCH_PASSWORD` | Sertifika deposu şifreleme parolası |
| Secret | `MATCH_GIT_BASIC_AUTHORIZATION` | Özel depoya erişen `kullanici:token` çiftinin base64 değeri |

`MATCH_GIT_BASIC_AUTHORIZATION` yalnızca sertifika deposuna gereken erişimi taşımalıdır. Secret değerlerini loglara veya uygulama paketine koymayın. `.xcconfig` yalnızca adres/kimlik taşır; TMDB, e-posta ve auth sırları sunucuda kalır.

## Dağıtım

```sh
cd ios
bundle exec fastlane ios beta
```

`beta`: canlı katalog kontrolü → geçici CI keychain → match → TestFlight'taki son build numarasını artırma → Release arşivi ve imzalı `.ipa` → TestFlight yükleme. Aynı uygulama için eşzamanlı yerel/CI yüklemesi başlatmayın.

GitHub Actions → **iOS validation and TestFlight** → Run workflow → `upload_testflight: true`. Normal push/PR yalnızca test çalıştırır. TestFlight lane'i çalışan bir sunucu yoksa yüklemeyi durdurur.

İstenen **macos-14** üzerinde Xcode 16.2 uyumluluk testleri korunur. Güncel App Store SDK şartını karşılamak için imzalı dağıtım **macos-26** üzerinde çalışır; SDK sürümü en az 26 olmalıdır. macos-14/Xcode 16.2 ile güncel TestFlight yüklemesi yapılamaz. Runner emeklilik tarihlerini takip edin.

Kaynaklar: [Apple SDK şartları](https://developer.apple.com/news/upcoming-requirements/), [GitHub macOS çalıştırıcıları](https://github.com/actions/runner-images), [Fastlane API Key](https://docs.fastlane.tools/app-store-connect-api/), [Fastlane match](https://docs.fastlane.tools/actions/match/).

## Gizlilik ve yayın kontrolü

- Uygulama içi JSON paylaşımı cihaz kayıtlarını ve giriş varsa hesap dışa aktarımını içerir. Son aramalar yalnızca cihazda bulunur.
- Hesap silme sunucu kaydını ve ilişkili verileri siler; yerel hesap listesi, platformları, kuyruk ve geçmiş de temizlenir. Misafir alanı bağımsızdır.
- Gizlilik manifesti, TMDB'nin resmi logo dosyası, zorunlu TMDB açıklaması ve JustWatch atfı eklenmiştir. Logo kaynağı: https://www.themoviedb.org/about/logos-attribution
- App Store Connect'te gizlilik beyanlarını gerçek sunucu loglama/saklama davranışıyla eşleştirin; gizlilik sayfasındaki veri sorumlusu, iletişim ve saklama süresi alanlarını tamamlayın. Ticari kullanım için TMDB/JustWatch lisans koşullarını karşılayın.
- Yayından önce gerçek sunucuyla kayıt, e-posta doğrulama, giriş, şifre sıfırlama, e-posta değişikliği, iki cihazda eşitleme, veri indirme ve silme akışlarını deneyin. Canlı sunucu ve Apple hesabı olmadan bu akışlar veya TestFlight teslimi doğrulanmış sayılmaz.

## GitHub'a gönderme

Çalışma `feat/cloudflare-platform` tabanlı `feat/native-ios` dalındadır; ana dalın üzerine yazılmaz.

```sh
git add ios app/api/mobile lib/mobile __tests__/mobile.test.ts __tests__/email.test.ts .github/workflows \
  .gitignore README.md lib/auth.ts lib/session.ts lib/cron/sync-providers.ts \
  app/api/user/delete/route.ts app/api/cron/sync/route.ts wrangler.jsonc lib/email.ts \
  .dev.vars.example .env.example
git commit -m "Add native CineSeeker iOS app and TestFlight pipeline"
git push -u origin feat/native-ios
```
