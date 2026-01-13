# CineSeeker Deployment Rehberi

Bu proje Next.js App Router ve Server Components kullandığı için **Node.js çalışma zamanına (runtime)** ihtiyaç duyar. Standart (sadece PHP/HTML destekleyen) bir paylaşımlı hosting'de doğrudan çalışmaz.

Ancak, hosting panelinizde (cPanel/Plesk) **Node.js desteği** varsa kurabilirsiniz.

İşte seçenekleriniz:

## Seçenek 1: Vercel (Önerilen)
Next.js'in yaratıcısı Vercel, en sorunsuz ve ücretsiz (hobi için) seçenektir.
1. GitHub reponuzu Vercel'e bağlayın.
2. Environment Variables kısmına `TMDB_API_KEY` ekleyin.
3. Deploy!

## Seçenek 2: Paylaşımlı Hosting (cPanel - Node.js Selector)
Eğer hostinginizde "Setup Node.js App" seçeneği varsa:

### 1. Hazırlık (Lokalde)
Projenizi "Standalone" modunda build almanız gerekir, bu sayede sadece gerekli dosyalar paketlenir.
`next.config.ts` dosyasını açın ve `output: 'standalone'` ekleyin:

```typescript
const nextConfig: NextConfig = {
  output: "standalone",
  // ... diğer ayarlar
};
```

Sonra build alın:
```bash
npm run build
```

Bu işlem `.next/standalone` klasörü oluşturur.

### 2. Dosyaları Hazırlama
Hosting'e yüklemeniz gerekenler sadece `.next/standalone` klasörünün **içindekilerdir**.
Ayrıca `.next/static` klasörünü de, standalone içindeki `.next/static` konumuna kopyalamanız gerekebilir veya public assets için ayrı ayar yapmalısınız.

**En Temiz Yöntem:**
1. `.next/standalone` içindeki her şeyi (public ve .next klasörleri dahil) bir ZIP yapın.
2. Ayrıca projenizin kök dizinindeki `public` klasörünü ve `.next/static` klasörünü de bu yapının içine (`.next/standalone/public` ve `.next/standalone/.next/static`) düzgünce yerleştiğinden emin olun. Standalone modu bazen static dosyalari kopyalamaz, manuel kopyalamanız gerekir:
   - `cp -r public .next/standalone/public`
   - `cp -r .next/static .next/standalone/.next/static`

### 3. Hosting'e Yükleme
1. cPanel > **Setup Node.js App** kısmına gidin.
2. Yeni uygulama oluşturun.
   - **Application Root**: `cineseeker`
   - **Application URL**: `siteniz.com`
   - **Startup File**: `server.js` (Standalone çıktısında bu dosya vardır)
   - **Node.js Version**: 18 veya 20 (Next.js 15 için güncel sürüm şart).
3. Dosya Yöneticisi ile oluşturulan klasöre (`cineseeker`) ZIP'i yükleyip açın.
4. `.env` dosyanızı oluşturun ve `TMDB_API_KEY=...` ekleyin.
5. Node.js App panelinden **Restart** yapın.

## Seçenek 3: Klasik Hosting (Sadece PHP/HTML) - DİKKAT
Eğer hostinginiz Node.js desteklemiyorsa bu projeyi **Static Export** (`output: 'export'`) ile dışa aktarabiliriz.

**ANCAK CİDDİ KISITLAMALAR OLUR:**
1. **API Key Güvenliği**: TMDB API key'iniz istemci tarafında (tarayıcıda) görünür hale gelir.
2. **Server Components**: Çalışmaz. Tüm `async function Page()` yapıları `use client`'a ve `useEffect` ile veri çekmeye dönüştürülmelidir.
3. **SSR**: SEO avantajı azalır (Pre-rendering çalışır ama dinamik içerik için JS şart olur).

Eğer Node.js desteğiniz yoksa ve Vercel kullanamıyorsanız, projeyi tamamen "Client-Side" (React SPA) mantığına çevirmem gerekir. Bu durumda API Key güvenliği için bir PHP Proxy yazmak zorunda kalırız.

**Tavsiyem:** Hostinginizde Node.js olup olmadığını kontrol edin. Yoksa Vercel kullanın.
