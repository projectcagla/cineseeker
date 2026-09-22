# Sunucusuz V1 doğrulaması — 22 Eylül 2026

| Kontrol | Sonuç |
|---|---|
| Swift 6 / Debug iOS Simulator derlemesi | Başarılı, Xcode 27.0 |
| iPhone 17 Pro / iOS 26.5 XCTest | 7 test, 0 hata |
| iPhone 18 Pro / iOS 27 XCTest | 7 test, 0 hata |
| Gerçek TMDB token ile katalog isteği | HTTP 200, 20 sonuç |
| Gerçek ayarla iOS 27 Debug derlemesi | Başarılı |
| Xcode Cloud hazırlık betiği | Eksik token reddi, dosya izinleri, anahtarsız log doğrulandı |
| Xcode 27 Release / generic iOS arşivi | Başarılı, Apple takımıyla imzalı; codesign doğrulaması geçti |
| Fastfile Ruby sözdizimi | Başarılı |
| V1 kaynaklarında özel sunucu/account çağrıları | Yok; katalog TMDB API, görseller TMDB CDN üzerinden |

Test kapsamı: film/dizi kimlik ayrımı; SwiftData yeniden açılışı; puan sınırları; arama geçmişi ve JSON dışa aktarımı; yerel verileri silme; sunucu işlem kuyruğunun oluşmaması; Bearer başlığının sabit TMDB adresine gönderilmesi; key'in URL'ye konmaması; son 180 gün ve TR/platform filtreleri; gerçek repository'nin test taşıyıcısıyla TV ayrıntısı ve Türkiye yayın verisini işlemesi.

Test ağ yanıtları yalnızca XCTest hedefindedir. Uygulama paketi örnek film kataloğu içermez. Gerçek TMDB token ile popüler film isteği başarılıdır; kapsamlı canlı arayüz ve fiziksel cihaz testleri henüz tamamlanmadı. Cloudflare, D1, Resend ve hesap sunucusu V1 için gerekli değildir.

TestFlight için dışa aktarılmış `.ipa`, TestFlight teslimi, GitHub-hosted macos-14/macos-26 çalışmaları, fiziksel cihaz, iOS 17 runtime ve geniş VoiceOver/Dynamic Type kontrolleri henüz doğrulanmadı. İmzasız `.xcarchive` dağıtılabilir bir TestFlight paketi değildir. Apple Developer kimliği ve imzalama secrets gereklidir.

Web/Cloudflare kodu bu V1 değişikliğinde değiştirilmedi. Önceki 16 Eylül 2026 kontrolünde web TypeScript, ESLint, 29 Vitest testi ve OpenNext üretim derlemesi başarılıydı; bunlar mobil V1 için kurulum gereksinimi değildir.

## Xcode Cloud durumu

Apple uygulama kaydı oluşturuldu (`6814588419`), GitHub bağlantısı kuruldu. `CineSeeker TestFlight` iş akışı `feat/native-ios` değişikliklerinde çalışacak şekilde kaydedildi; zorunlu iOS 27 testi ve dahili TestFlight arşiv hazırlığı eklendi. `CineSeeker Internal` grubu oluşturuldu. Xcode 27 sabitlemesi ve TestFlight grup bağlantısının son düzenlemeleri sürüyor. TMDB Cloud secret ve hesap sahibinin test grubuna eklenmesi için onay bekleniyor. İlk varsayılan `main` denemesi başarısız; bu dalda iOS projesi bulunmuyor. Başarılı Cloud arşivi ve TestFlight yüklemesi henüz doğrulanmadı.
