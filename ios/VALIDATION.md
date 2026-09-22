# CineSeeker 1.1.0 — doğrulama raporu

22 Eylül 2026. Xcode 27.0 (27A266a), Swift 6, iOS 27 SDK; minimum dağıtım hedefi iOS 17.

## Bu sürümde yapılan kontroller

| Kontrol | Sonuç |
|---|---|
| iPhone 18 Pro / iOS 27 | 16 birim + 2 arayüz testi, 0 hata |
| iPad Pro 11-inch (M5) / iOS 27 | 16 birim + 2 arayüz testi, 0 hata |
| Büyük yazı | En büyük erişilebilirlik boyutunda keşfet, liste ve platform gezinmesi |
| Release / generic iOS | 1.1.0 arşivi Apple geliştirme takımıyla imzalı oluşturuldu |
| İmza bütünlüğü | `codesign --verify --deep --strict` başarılı |
| Web TypeScript / ESLint | Başarılı |
| Web Vitest | 29 test, 0 hata |
| Next.js / OpenNext üretim derlemesi | Başarılı |
| Marka dosyaları | SVG/PNG kapak, 1024 px opak ikon ve simülatör ekranları görsel olarak incelendi |

## Regresyon kapsamı

- Film/dizi kimlik ayrımı, durum ve puan sınırları, JSON dışa aktarımı, yerel veri silme.
- SwiftData dosyasının yeni bir konteynerde yeniden açılması; liste ve platform kalıcılığı.
- Kaydedilen içeriğin değişen adı/afişinin çevrimdışı kayda yansıması.
- Türkçe İ/i, ı/I ve aksansız arama; durum filtresi ile puan sıralamasının birlikte çalışması.
- Başarısız katalog yenilemesinin mevcut sonuçları koruması.
- İptal edilen film türü isteğinin yeni dizi türlerini ezmemesi.
- Yayın seçenekleri servisi hata verse de detay metni ve sürenin kullanılabilmesi.
- Başarılı ancak Türkiye yayını içermeyen yanıtın eski seçenekleri kaldırması.
- Veri silmenin önceki açılıştan kalan geçici JSON dosyasını temizlemesi.
- Bearer başlığı ve sabit TMDB adresi; anahtarın URL’ye eklenmemesi.
- Türkiye, platform ve son 180 gün filtreleri; gerçek repository ile TV yanıtı çözümleme.
- Arayüzde dört ana sekme, görünür arama alanları, sıralama menüsü ve platform ekranına geçiş.

Arayüz testleri canlı katalog sonucuna bağımlı değildir; ana gezinmenin internet olmadığında da kullanılmasını kontrol eder. Ağ yanıtı örnekleri yalnızca test hedeflerinde yer alır. Uygulama sahte içerik kataloğu kullanmaz. Yerel ekran görüntülerinde gerçek TMDB içeriği de görüntülendi.

## Xcode Cloud ve TestFlight

`CineSeeker TestFlight`, `feat/native-ios` GitHub dalına bağlıdır. Apple uygulaması `6814588419`; Bundle ID `com.projectcagla.cineseeker`.

Önceki sürümün Xcode Cloud **Test, Build ve Archive** sonuçları GitHub Checks üzerinden başarıyla doğrulandı (commit `ebf321d`, Cloud build `164e4401-d17e-40ed-a3fe-2ffddbe9b8d6`). İlk TestFlight sürümünün çalıştığı hesap sahibi tarafından ayrıca doğrulandı.

Bu rapordaki yerel arşiv başarısı, yeni sürümün TestFlight’a teslim edildiği anlamına gelmez. Yeni gönderimin Cloud kontrolü GitHub üzerinden, TestFlight işlemesi ise App Store Connect üzerinden izlenir. Son kontrolde bu bilgisayardaki Apple web oturumu yeniden giriş gerektiriyordu.

## Sınırlar

- Fiziksel cihazda bu sürüm ve tam VoiceOver denetimi yapılmadı.
- iOS 17 simülatör runtime’ı yerelde bulunmadığından gerçek iOS 17 çalıştırması doğrulanmadı.
- Büyük yazı testleri temel ekranları kapsar; tüm katalog başlıkları ve tüm ekran boyutları için kusursuzluk iddiası değildir.
- Katalog/yayın seçenekleri dış servislere bağlıdır. V1 çevrimdışı listeleri açar; henüz önbelleğe alınmamış görseller ve yeni aramalar internet ister.
- V1 hesap açmaz, giriş yapmaz, sunucuya senkronizasyon göndermez. Cloudflare/D1/Resend kurulumu gerektirmez.
