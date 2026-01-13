# CineSeeker

Türkiye pazarına odaklı, JustWatch tarzı minimal "nerede izlenir?" film keşif uygulaması.

## Özellikler

- **Türkiye Odaklı**: Sadece Türkiye'de erişilebilir (Netflix, Prime, BluTV, Mubi vb.) içerikleri gösterir.
- **Minimal Tasarım**: Odak sadece film ve izleme linkinde.
- **Hızlı ve SEO Dostu**: Next.js App Router ve SSR.
- **Akıllı Arama**: Türkçe ve Orijinal isimle arama.

## Teknoloji Stack

- Next.js 15 (App Router)
- TypeScript
- TailwindCSS
- TMDB API

## Kurulum

1. Repoyu klonlayın:
   ```bash
   git clone <repo-url>
   cd cineseeker
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   npm install
   ```

3. Çevre değişkenlerini ayarlayın:
   `.env.local` dosyası oluşturun ve TMDB API Key ekleyin.
   ```env
   TMDB_API_KEY=your_tmdb_api_key_here
   ```
   *Key almak için: [TheMovieDB API](https://www.themoviedb.org/documentation/api)*

4. Geliştirme sunucusunu başlatın:
   ```bash
   npm run dev
   ```

## Kullanılan API Endpoint'leri

- `/discover/movie`: Popüler ve yeni filmler (watch_region=TR filtresi ile).
- `/movie/{id}`: Film detayları.
- `/movie/{id}/watch/providers`: Türkiye izleme seçenekleri.
- `/person/{id}`: Yönetmen/Oyuncu detayları ve filmografisi.
- `/search/movie`: Film arama.

## Lisans

MIT
