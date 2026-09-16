# Doğrulama — 16 Eylül 2026

Bu kayıt yerel olarak yapılan kontrolleri ve henüz doğrulanamayan dağıtım adımlarını ayırır.

| Kontrol | Sonuç |
|---|---|
| Swift 6 / Debug iOS Simulator derlemesi | Başarılı, Xcode 27.0 (27A266a) |
| iPhone 17 Pro / iOS 26.5 XCTest | 4 test, 0 hata |
| Release / generic iOS arşivi | Başarılı, CODE_SIGNING_ALLOWED=NO |
| Simülatörde uygulama başlatma | Başarılı; sunucu kurulmamış durum ekranı görsel olarak kontrol edildi |
| TypeScript `tsc --noEmit` | Başarılı |
| ESLint | Başarılı |
| Vitest | 29 test, 0 hata |
| OpenNext Cloudflare worker üretim derlemesi | Başarılı |
| Fastfile Ruby sözdizimi | Başarılı |

XCTest kapsamı: film/dizi anahtar ayrımı; SwiftData yeniden açılışında kalıcılık; hesap izolasyonu; puan sınırları ve puanı kaldırma; son aramalar ve JSON dışa aktarma; kalıcı işlem kuyruğu; hesap verisi silinirken misafir verilerinin korunması.

Yeni sunucu testleri: katalog parametre sınırları, geçerli ve taze oturum gereksinimi, aynı Origin kontrolü, başka hesaba ait kuyruk işleminin reddi, Türkiye TV yayın seçenekleri, upstream hata ayrımı ve e-posta teslim hata davranışı. Mevcut web testleri de geçer.

Henüz doğrulanmadı: canlı D1/TMDB/Resend ile uçtan uca hesap ve katalog akışları; imzalı `.ipa`; Apple Developer sertifikası/profili; TestFlight kabulü; GitHub-hosted macos-14 testi ve macos-26 beta lane'i. Canlı sunucu, kayıtlı Bundle ID, Apple üyeliği ve gerekli secrets bu çalışma sırasında mevcut değildi. İmzasız `.xcarchive` App Store'a yüklenebilir bir teslim değildir.

iOS 17 minimum hedefi derleme ayarıyla korunur; bu makinede çalıştırılan runtime iOS 26.5'tir. Fiziksel cihaz, iOS 17 runtime, geniş Dynamic Type/VoiceOver kullanım testi ve gerçek katalogla ekran değerlendirmesi dağıtım öncesi tamamlanmalıdır.
