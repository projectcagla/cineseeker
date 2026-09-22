# CineSeeker — görsel kimlik

**Aradığın hikâye. İzleyeceğin yer.**

CineSeeker’in işareti bir film şeridinin devamlılığını S harfine dönüştürür. Yuvarlatılmış dönüşler akışı, 45° kesimler kurgu birleşimini anlatır. İşaretin içine oynat düğmesi, film makarası veya ek sembol konmaz.

## Dosyalar

| Dosya | Kullanım |
|---|---|
| [mark.svg](../../public/brand/mark.svg) | Şeffaf zeminde turuncu sembol |
| [mark-mono.svg](../../public/brand/mark-mono.svg) | Tek renk; `currentColor`, varsayılan siyah |
| [wordmark.svg](../../public/brand/wordmark.svg) | Koyu zemin üzerinde yatay logo |
| [wordmark-light.svg](../../public/brand/wordmark-light.svg) | Açık zemin üzerinde yatay logo |
| [app-icon.png](../../public/brand/app-icon.png) | 1024 × 1024, opak iOS uygulama ikonu |
| [icon.svg](../../public/brand/icon.svg) | Web favicon |
| [github-cover.svg](../../public/brand/github-cover.svg) | GitHub README kapağı, 1280 × 640 |
| [github-cover.png](../../public/brand/github-cover.png) | GitHub sosyal paylaşım görseli |

## Palet ve tipografi

- **Gece:** `#0A0A0A` — ana zemin.
- **Kurgu turuncusu:** `#FF8534` — marka işareti.
- **Kâğıt:** `#F5F2EB` — ana metin.
- **Taş:** `#A8A49E` — yardımcı metin.
- **Nane:** `#66DBA6` — yalnızca abonelik/onay durumu; marka renginin yerine kullanılmaz.

iOS’ta sistem yazısı ve Dynamic Type kullanılır. Yatay marka yazısı Helvetica Neue, Arial veya sans-serif ile yarı kalın, sıkı harf aralığında dizilir. Uzun metinler normal ağırlıktadır. Büyük harf yalnızca kısa üst etiketlerde kullanılır.

Sembolün çevresinde yüksekliğinin en az dörtte biri kadar boşluk bırak. Sembolü en az 24 px, yatay logoyu en az 140 px genişlikte kullan. Oranları değiştirme; gölge, parlama, kontur veya ayrı bir degrade ekleme. Uygulama ikonunun köşelerini dosyada kesme; iOS maskesi uygular.

## Yeniden üretim

`feat/native-ios` dalının depo kökünde:

```sh
python3 scripts/generate-brand.py
swift ios/scripts/draw_icon.swift ios/CineSeeker/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png
cp ios/CineSeeker/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png public/brand/app-icon.png
node -e "require('sharp')('public/brand/github-cover.svg').png().toFile('public/brand/github-cover.png')"
python3 ios/scripts/generate_project.py
```

Vektörler ve SwiftUI sembolü aynı geometriden üretilir. Ana geometri `scripts/generate-brand.py` içindedir. PNG üretimi macOS CoreGraphics; kapak dönüşümü web projesindeki Sharp ile yapılır.
