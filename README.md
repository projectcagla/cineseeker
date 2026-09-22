<p align="center">
  <img src="https://raw.githubusercontent.com/projectcagla/cineseeker/feat/native-ios/public/brand/github-cover.svg" alt="CineSeeker — Aradığın hikâye. İzleyeceğin yer." width="100%" />
</p>

<p align="center">
  <strong>Türkiye için film ve dizi keşif rehberi.</strong><br />
  Ne izleyeceğini bul. Hangi platformda olduğunu gör. Kendi sinema günlüğünü tut.
</p>

<p align="center">
  <img alt="Swift 6" src="https://img.shields.io/badge/Swift-6-FF8534?style=flat-square&amp;logo=swift&amp;logoColor=white" />
  <img alt="iOS 17 ve üzeri" src="https://img.shields.io/badge/iOS-17%2B-151515?style=flat-square&amp;logo=apple" />
  <img alt="SwiftUI ve SwiftData" src="https://img.shields.io/badge/SwiftUI-SwiftData-151515?style=flat-square" />
  <img alt="Sunucusuz V1" src="https://img.shields.io/badge/V1-Sunucusuz-151515?style=flat-square" />
</p>

<p align="center">
  <a href="https://github.com/projectcagla/cineseeker/tree/feat/native-ios/ios">iOS uygulaması</a> ·
  <a href="https://github.com/projectcagla/cineseeker/blob/feat/native-ios/ios/README.md">Kurulum &amp; TestFlight</a> ·
  <a href="https://github.com/projectcagla/cineseeker/blob/feat/native-ios/ios/VALIDATION.md">Test sonuçları</a> ·
  <a href="https://github.com/projectcagla/cineseeker/blob/feat/native-ios/docs/brand/README.md">Marka dosyaları</a>
</p>

## Bir sonraki iyi hikâye

CineSeeker, Türkiye’deki yayın seçeneklerini tek yerde toplar. Abonelik, kiralama ve satın alma seçeneklerini ayırır; seçtiğin platformları öne çıkarır. İçerikleri **İzlemek İstiyorum / İzliyorum / İzledim** durumlarıyla kaydedebilir, kendi puanını verebilirsin.

| Keşfet | Kendine göre düzenle | Yanında tut |
| :--- | :--- | :--- |
| Popüler ve yeni çıkan film/diziler | Abone olduğun platformlara göre filtre | Çevrimdışı izleme listesi |
| Türkçe ve orijinal adla arama | Tür, durum ve puana göre düzenleme | 1–10 kişisel puan |
| Oyuncular, özet ve yayın seçenekleri | Kart veya liste görünümü | JSON veri dışa aktarımı |

**V1 sunucu istemez.** Katalog doğrudan TMDB’den gelir. Liste, puanlar, platform seçimleri ve arama geçmişi SwiftData ile cihazda tutulur. Katalog için internet gerekir; kaydedilmiş liste çevrimdışı açılır. Cihazlar arası eşitleme ve hesap sistemi V2 kapsamındadır.

## Uygulamadan

<p align="center">
  <img src="https://raw.githubusercontent.com/projectcagla/cineseeker/feat/native-ios/docs/screenshots/01-Discover.png" width="30%" alt="CineSeeker Keşfet ekranı" />
  <img src="https://raw.githubusercontent.com/projectcagla/cineseeker/feat/native-ios/docs/screenshots/02-Search.png" width="30%" alt="Film ve dizi araması" />
  <img src="https://raw.githubusercontent.com/projectcagla/cineseeker/feat/native-ios/docs/screenshots/05-Platforms.png" width="30%" alt="Platform aboneliği tercihleri" />
</p>

Gerçek uygulamadan, iPhone / iOS 27 simülatörü. Katalog görselleri TMDB kaynaklıdır.

## iOS’u çalıştır

Güncel yerel uygulama **`feat/native-ios`** dalındadır. `main` web sürümünü korur; iOS dağıtımını aşağıdaki dal yürütür.

```sh
git clone --branch feat/native-ios https://github.com/projectcagla/cineseeker.git
cd cineseeker
cp ios/Config/Config.example.xcconfig ios/Config/Config.xcconfig
open ios/CineSeeker.xcodeproj
```

`Config.xcconfig` içindeki `TMDB_READ_TOKEN` alanını kendi TMDB **API Read Access Token** değerinle doldur. Dosya Git dışında tutulur; mevcut ayar dosyan varsa üzerine kopyalama. Xcode’da **CineSeeker** şemasını ve bir iPhone/iPad simülatörünü seçip çalıştır. Yerel geliştirme Xcode 27 / Swift 6 ile doğrulanır; en düşük dağıtım hedefi iOS 17’dir.

Mobil uygulamaya eklenen ortak okuma token’ı dağıtılan paketten çıkarılabilir. V1’de yalnızca TMDB okuma yetkisi kullanılır; Apple veya sunucu anahtarları uygulamaya eklenmez. [Ayrıntılı yapılandırma ve gizlilik sınırları](https://github.com/projectcagla/cineseeker/blob/feat/native-ios/ios/README.md).

## GitHub → Xcode Cloud → TestFlight

**CineSeeker TestFlight** iş akışı `feat/native-ios` dalındaki güncellemeleri alır, test eder ve arşivler. Başarılı dağıtım Apple’ın işleme aşamasından sonra dahili TestFlight grubuna ulaşır. Yeni derlemeyi almak için TestFlight’ta güncelleme veya otomatik güncellemeler kullanılır.

Cloud ayarları Apple hesabında tutulur. `TMDB_READ_TOKEN` Xcode Cloud’da **Secret** olarak tanımlanır; imzalama Xcode Cloud tarafından yönetilir. İlk TestFlight sürümünün çalıştığı hesap sahibi tarafından doğrulanmıştır. Her yeni sürümün durumu ayrıca Cloud raporundan takip edilmelidir.

[Dağıtım rehberi](https://github.com/projectcagla/cineseeker/blob/feat/native-ios/ios/README.md#xcode-cloud-ile-otomatik-testflight) · [1.1.0 değişiklikleri](https://github.com/projectcagla/cineseeker/blob/feat/native-ios/ios/CHANGELOG.md)

## Kod haritası

```text
ios/
  CineSeeker.xcodeproj   Paylaşılan Xcode projesi ve şeması
  CineSeeker/
    App/                Uygulama başlangıcı ve gezinme
    Core/               Ağ, görüntü önbelleği, SwiftData, tasarım sistemi
    Domain/ + Models/   Katalog sözleşmeleri ve veri modelleri
    Data/               Canlı TMDB deposu
    Features/           Keşfet, arama, detay, liste, platformlar, ayarlar
  CineSeekerTests/       Veri, ağ ve hata senaryoları
  CineSeekerUITests/     Ekranlar arası gezinme ve ekran görüntüleri
  ci_scripts/           Xcode Cloud hazırlığı
public/brand/           Logo, uygulama ikonu ve GitHub kapak görseli
docs/brand/             Kurumsal kimlik ve kullanım kuralları
app/ + components/      Next.js web uygulaması
```

Web ve Cloudflare altyapısı depoda korunur. iOS V1’i kullanmak için bunları dağıtmak gerekmez. Web geliştirme ve ilerideki sunucu seçenekleri için [V2 rehberi](https://github.com/projectcagla/cineseeker/blob/feat/native-ios/ios/BACKEND.md).

## Kimlik ve katkı

CineSeeker’in işareti, film şeridinin devamlılığından ve kurgu kesiminden türetilen **S monogramıdır**. Koyu zemin, sıcak turuncu vurgu ve sade tipografi uygulama ile depo görsellerinde ortaktır. Açık/koyu zemin logoları, tek renk sürüm ve uygulama ikonu [marka paketinde](https://github.com/projectcagla/cineseeker/tree/feat/native-ios/public/brand) bulunur.

Bir sorun bildirmek için [Issues](https://github.com/projectcagla/cineseeker/issues) bölümüne cihazı, iOS sürümünü ve tekrar üretme adımlarını ekle. Token veya kişisel veri paylaşma.

## Veri kaynakları

Film/dizi bilgileri ve görseller **TMDB**, yayın seçenekleri **JustWatch** kaynaklıdır. Platform katalogları ve fiyatlar değişebilir; güncel koşullar yayın sağlayıcısında doğrulanmalıdır. “Yeni çıkanlar” içeriğin çıkış tarihini esas alır, platforma eklendiği tarihi ifade etmez.

> This product uses the TMDB API but is not endorsed or certified by TMDB.

[TMDB](https://www.themoviedb.org/) · [JustWatch](https://www.justwatch.com/tr)
