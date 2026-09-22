# CINE/SEEKER — minimal brutalist kimlik

**AZ GEZİN. İYİ İZLE.**

Kimlik tipografiktir: tam yazım **CINE/SEEKER**, dar alanlarda **C/**. Eğik çizgi keşiften izlemeye geçişi ayırır. Ek maskot, oynat düğmesi veya süslü monogram kullanılmaz.

## Marka paketi

| Dosya | Kullanım |
|---|---|
| [wordmark.svg](../../public/brand/wordmark.svg) | Koyu zeminde tam logo |
| [wordmark-light.svg](../../public/brand/wordmark-light.svg) | Açık zeminde tam logo |
| [mark.svg](../../public/brand/mark.svg) | Koyu zeminde C/ |
| [mark-mono.svg](../../public/brand/mark-mono.svg) | Tek renk `currentColor` |
| [app-icon.png](../../public/brand/app-icon.png) | 1024 × 1024, opak iOS ikonu |
| [icon.svg](../../public/brand/icon.svg) | Web ikonu |
| [github-cover.svg](../../public/brand/github-cover.svg) | Ölçeklenebilir README kapağı |
| [github-cover.png](../../public/brand/github-cover.png) | 1280 × 640 sosyal paylaşım görseli |

## Görsel kurallar

- Zemin `#0A0A0A`, yazı `#F4F4EF`, vurgu `#FF5C29`.
- Tipografi: koyu grotesk başlıklar; teknik etiketlerde monospaced sistem yazısı. iOS’ta Dynamic Type korunur.
- Köşeler keskin, yüzeyler düz, ayırıcı çizgiler incedir. Dekoratif gölge, parlama ve renkli degrade kullanılmaz. Afişin üzerinde metin okunurluğu için siyah geçiş kullanılabilir.
- Ana işlem siyah-beyaz bloktur. Turuncu kısa vurgu ve aktif durumlar içindir; yeşil yalnızca abonelik durumunu belirtir.
- Native gezinme, arama ve paylaşım kontrolleri işletim sisteminin erişilebilir davranışını korur.
- Logonun çevresinde harf yüksekliğinin yarısı kadar boşluk bırak. C/ en az 24 px; tam logo en az 140 px genişlikte kullanılmalıdır.
- Uygulama ikonunun köşelerini dosyada kesme; maskeyi iOS uygular.

## Yeniden üretim

`feat/native-ios` dalının kökünde:

```sh
python3 scripts/generate-brand.py
swift ios/scripts/draw_icon.swift ios/CineSeeker/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png
cp ios/CineSeeker/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png public/brand/app-icon.png
node scripts/render-brand.mjs
python3 ios/scripts/generate_project.py
```

SVG kaynakları Python, uygulama ikonu CoreGraphics/CoreText ve web çıktı dosyaları projenin Sharp bağımlılığı ile üretilir.
