# Sunucusuz V1 doğrulaması — 20 Eylül 2026

| Kontrol | Sonuç |
|---|---|
| Swift 6 / Debug iOS Simulator derlemesi | Başarılı, Xcode 27.0 |
| iPhone 17 Pro / iOS 26.5 XCTest | 7 test, 0 hata |
| Release / generic iOS arşivi | Başarılı, CODE_SIGNING_ALLOWED=NO |
| Fastfile Ruby sözdizimi | Başarılı |
| V1 kaynaklarında özel sunucu/account çağrıları | Yok; katalog TMDB API, görseller TMDB CDN üzerinden |

Test kapsamı: film/dizi kimlik ayrımı; SwiftData yeniden açılışı; puan sınırları; arama geçmişi ve JSON dışa aktarımı; yerel verileri silme; sunucu işlem kuyruğunun oluşmaması; Bearer başlığının sabit TMDB adresine gönderilmesi; key'in URL'ye konmaması; son 180 gün ve TR/platform filtreleri; gerçek repository'nin test taşıyıcısıyla TV ayrıntısı ve Türkiye yayın verisini işlemesi.

Test ağ yanıtları yalnızca XCTest hedefindedir. Uygulama paketi örnek film kataloğu içermez. TMDB token'ı sağlanmadığı için gerçek TMDB yanıtlarıyla canlı uçtan uca katalog testi yapılmadı. Cloudflare, D1, Resend ve hesap sunucusu V1 için gerekli değildir.

İmzalı `.ipa`, TestFlight teslimi, GitHub-hosted macos-14/macos-26 çalışmaları, fiziksel cihaz, iOS 17 runtime ve geniş VoiceOver/Dynamic Type kontrolleri henüz doğrulanmadı. İmzasız `.xcarchive` dağıtılabilir bir TestFlight paketi değildir. Apple Developer kimliği ve imzalama secrets gereklidir.

Web/Cloudflare kodu bu V1 değişikliğinde değiştirilmedi. Önceki 16 Eylül 2026 kontrolünde web TypeScript, ESLint, 29 Vitest testi ve OpenNext üretim derlemesi başarılıydı; bunlar mobil V1 için kurulum gereksinimi değildir.
