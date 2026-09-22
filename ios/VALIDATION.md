# CineSeeker 1.3.0 — doğrulama raporu

22 Eylül 2026. Xcode 27.0 (27A266a), Swift 6, iOS 27 SDK; minimum dağıtım hedefi iOS 17.

## Bu sürümde yapılan kontroller

| Kontrol | Sonuç |
|---|---|
| iPhone 18 Pro / iOS 27 | 28 birim + 2 arayüz testi, 0 hata |
| iPad Pro 11-inch (M5) / iOS 27 | 28 birim + 2 arayüz testi, 0 hata |
| Büyük yazı | En büyük erişilebilirlik boyutunda keşfet, liste ve platform gezinmesi |
| Release / generic iOS | 1.3.0 arşivi Apple geliştirme takımıyla imzalı oluşturuldu |
| İmza bütünlüğü | `codesign --verify --deep --strict` başarılı |
| Web TypeScript / ESLint / Vitest / OpenNext | Önceki doğrulama başarılı, 29 test; bu sürüm web işlevlerini değiştirmez |
| Marka dosyaları | SVG/PNG kapak, 1024 px opak ikon ve simülatör ekranları görsel olarak incelendi |

Ana matris toplam **60 test çalıştırması**, sıfır hata ve sıfır runtime uyarısı içerir. Canlı katalog testi bu matristen ayrı yürütülür.

## 1.3 kişi ve keşif doğrulaması

- Aynı filmde oyunculuk/yönetmenlik/senaryo katkılarının birleştirilmesi; film ve TV kimliklerinin ayrı tutulması.
- Katkı, içerik türü ve Türkçe karakterli metin filtrelerinin birlikte çalışması; tarihsiz kayıtların her iki tarih sıralamasında sonda kalması.
- Türkçe biyografi eksikse İngilizceye geçiş; bu ek istek başarısız olsa da filmografinin korunması.
- Başarısız yenilemede son başarılı kişi verilerinin korunması.
- Resmi/Türkçe fragman önceliği, YouTube site/kimlik denetimi; ilişkili yapımlarda tekrar ve kaynak yapımın elenmesi.
- Eksik filmografi yanıtının önbellekteki yayın seçeneklerini silmemesi; doğrulanmış boş yanıtın eski seçenekleri kaldırması.
- Gerçek TMDB verisiyle iPhone’da **Dövüş Kulübü → David Fincher → filmografide arama → Dövüş Kulübü** geçişi başarılı. İlk denemede saptanan karışık gezinme türleri sorunu ortak Movie/PersonRoute yönlendirmesiyle giderildi ve aynı akış yeniden geçti.
- Aynı canlı geçiş iPad’de ve iPhone’un en büyük erişilebilirlik yazı boyutunda da geçti; bağlantılı yapımlar bölümüne ulaşılması ayrıca doğrulandı. Ana matrise ek üç başarılı canlı çalışma vardır.

Standart CI dış kataloğa bağımlı değildir. `CINESEEKER_LIVE_UI=1` ile açılan ek canlı test geçerli token ister; bu değişken yokken yalnızca o test gerekçesiyle atlanır.

## Öneri doğrulaması

TMDB `/movie/{id}/recommendations` canlı okuma anahtarıyla HTTP 200 ve 20 sonuç döndürdü. Testler olumlu puanların önceliğini, izlenen/izlenen devam/düşük puanlı içeriklerin elenmesini, kiralamanın abonelik sayılmamasını, geçmiş yokken genel seçkiyi, tekrar önlemeyi ve ağ hatasından çıkışı kapsar.

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

1.1.0 öncesi sürümün Xcode Cloud **Test, Build ve Archive** sonuçları GitHub Checks üzerinden başarıyla doğrulandı (commit `ebf321d`, Cloud build `164e4401-d17e-40ed-a3fe-2ffddbe9b8d6`). İlk TestFlight sürümünün çalıştığı hesap sahibi tarafından ayrıca doğrulandı.

1.1.0 gönderimi `cbbc38d` için Xcode Cloud Test, Build ve Archive işlemleri de başarılıdır. GitHub Xcode 16.2 denemesinde bulunan fonksiyon referansı derleme hatası 1.2.0’da açık closure kullanımıyla giderildi.

1.2.0 gönderimi `876fc36` için GitHub iOS/web kontrolleri ve Xcode Cloud **Test, Build ve Archive** işlemlerinin tamamı başarılı doğrulandı. 1.3.0 bu rapordaki yeni yerel doğrulamayı içerir; kendi Cloud sonucu ayrıca kontrol edilir.

Bu rapordaki yerel arşiv başarısı, yeni sürümün TestFlight’a teslim edildiği anlamına gelmez. Yeni gönderimin Cloud kontrolü GitHub üzerinden, TestFlight işlemesi ise App Store Connect üzerinden izlenir. Son kontrolde bu bilgisayardaki Apple web oturumu yeniden giriş gerektiriyordu.

## Sınırlar

- Fiziksel cihazda bu sürüm ve tam VoiceOver denetimi yapılmadı.
- iOS 17 simülatör runtime’ı yerelde bulunmadığından gerçek iOS 17 çalıştırması doğrulanmadı.
- Büyük yazı testleri temel ekranları kapsar; tüm katalog başlıkları ve tüm ekran boyutları için kusursuzluk iddiası değildir.
- Katalog/yayın seçenekleri dış servislere bağlıdır. V1 çevrimdışı listeleri açar; henüz önbelleğe alınmamış görseller ve yeni aramalar internet ister.
- V1 hesap açmaz, giriş yapmaz, sunucuya senkronizasyon göndermez. Cloudflare/D1/Resend kurulumu gerektirmez.
