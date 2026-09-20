# V2 için arşivlenmiş sunucu rehberi

**iOS V1 sunucusuzdur. Bu adımları V1 için uygulamayın.** Güncel kurulum: [V1 rehberi](README.md). Aşağıdaki yapı V2 hesap/eşitleme çalışması için korunmuştur.

# iOS için canlı sunucu

Bu dal Cloudflare D1 ve Better Auth kullanır. Ücretli özel alan adı gerekmez; Cloudflare Workers HTTPS adresi yeterlidir. iOS projesi `API_BASE_URL` ayarlanmadan da derlenir, fakat katalog/hesap sunucusu olmadan çevrimiçi akışlar çalışmaz.

1. Cloudflare hesabınızda Workers ve D1 erişimini etkinleştirin. Depo kökünde `npm ci` ve `npx wrangler login` çalıştırın.
2. `npx wrangler d1 create cineseeker-db` ile veritabanı oluşturun. Çıktıdaki **gerçek** `database_id` değerini `wrangler.jsonc` içindeki üretim `DB` binding'ine yazın; örnek ID ile dağıtmayın.
3. `npm run db:migrate:prod` ile şemayı uygulayın.
4. `wrangler.jsonc` içine üretim adresinizle `vars: { "NEXT_PUBLIC_APP_URL": "https://...workers.dev" }` ekleyin. Yerelde `.dev.vars.example` dosyasını `.dev.vars` olarak kopyalayın.
5. `npx wrangler secret put TMDB_API_KEY`, `BETTER_AUTH_SECRET`, `RESEND_API_KEY`, `RESEND_FROM_EMAIL`, `CRON_SECRET` komutlarını ayrı ayrı çalıştırın. Her komut değeri etkileşimli ister. Auth ve cron için birbirinden farklı güçlü rastgele değerler kullanın. TMDB anahtarı iOS içine girmez. E-posta gönderen alan adınızı Resend'de doğrulayın ve `RESEND_FROM_EMAIL` değerini doğrulanmış alan adınızdaki göndericiye ayarlayın.
6. `npm run build:worker` ve `npm run deploy` çalıştırın. Cloudflare'ın gösterdiği HTTPS adresiyle `NEXT_PUBLIC_APP_URL` değerinin tam eşleştiğini kontrol edin.
7. `/api/mobile/catalog?action=genres&media=movie` adresinin 200 ve gerçek türler döndürdüğünü kontrol edin. Uygulamanın `Config.xcconfig` dosyasına bu kök adresi girin.
8. GitHub repository variable `API_BASE_URL` ve repository secret `CRON_SECRET` ekleyin. `provider-sync.yml` her gün 03:00 UTC'de film/dizi platformlarını tarar; schedule yalnızca varsayılan dalda etkindir. İlk taramayı workflow_dispatch ile başlatabilirsiniz. Başarılı yanıtın `errors` alanını inceleyin. Bu tarama örneklemdir, tüm Türkiye kataloğunu kapsamaz.
9. Cloudflare tarafında `/api/mobile/catalog` için uygun oran sınırı belirleyin. Kamuya açık katalog erişimi sunucu TMDB kotasını kullanır.

Mobil uç noktalar:

- `GET /api/mobile/catalog?action=discover|search|detail|providers|genres|arrivals&media=movie|tv`
- `GET /api/mobile/library` — oturum sahibinin listesi ve abonelikleri
- `POST /api/mobile/library` — doğrulanmış `save`, `remove`, `provider` işlemleri; idempotent upsert/delete
- `/api/auth/*` — mevcut Better Auth uçları
- `GET /api/user/export`, `POST /api/user/delete` — KVKK akışları

JSON mutasyonları aynı Origin ve geçerli sunucu oturumu gerektirir. Mobil eşitleme ayrıca `X-CineSeeker-User` ile kuyruk sahibini doğrular. Hesap silme ve eşitleme taze oturum sorgular; iptal edilmiş oturum cookie önbelleğine güvenilmez.

`POST /api/cron/sync`, `Authorization: Bearer …` gerektirir; gizli değer tanımlanmamışsa da istek reddedilir. URL üzerinden secret gönderilmez. Zamanlama GitHub Actions üzerinden yapıldığı için doğrudan scheduled handler içermeyen OpenNext worker'a etkisiz bir Wrangler cron kaydı eklenmez.
