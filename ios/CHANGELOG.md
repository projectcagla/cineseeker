# Sürüm notları

## 1.3.0

- Minimal brutalist kimliğe editoryal tipografi, italik serif vurgular, siyah-beyaz portreler ve daha dengeli bölüm aralıkları eklendi. CINE/SEEKER logosu korundu.
- Oyuncu, yönetmen, senarist ve dizi yaratıcısı kartları kişi sayfasına açılır.
- Biyografi, doğum bilgileri ve film/dizi filmografisi; katkı türü filtresi, metin araması ve popülerlik/tarih sıralaması.
- Aynı yapımdaki birden fazla katkı tek kartta birleştirilir; film ve dizilerin aynı sayısal kimlikleri birbirine karışmaz.
- Türkçe biyografi yoksa açıkça belirtilen İngilizce metin gösterilir. Biyografi isteği başarısız olsa da filmografi kullanılabilir.
- Film ve dizi detayında YouTube fragmanı, bağlantılı yapımlar ve kişi paylaşımı.
- Film → kişi → film geçişleri ortak gezinme sistemiyle çalışır; filmografi kartlarından izleme listesine hızlı ekleme korunur.
- Eksik filmografi verisinin önceden kaydedilmiş afiş ve yayın seçeneklerini silmesi önlendi; doğrulanmış boş yayın yanıtı eski seçenekleri temizler.
- Filmografi, biyografi hataları, fragman güvenliği ve önbellek güncellemeleri için testler; canlı katalogla kişi gezinme testi.

## 1.2.0

- Minimal brutalist arayüz: düz siyah-beyaz yüzeyler, keskin kartlar, güçlü tipografi, çizgili filtreler ve sınırlı turuncu vurgu.
- Tipografik CINE/SEEKER logosu ve C/ uygulama ikonu; GitHub kimliği yenilendi.
- “Bana bir film seç”: yüksek puanlı ve izlenmiş filmlerden kişisel rastgele öneri, seçilme nedeni ve başka film seçimi.
- İzlenen/izlenmekte olan ve düşük puanlı filmleri eleme; isteğe bağlı abonelik filtresi.
- Yeni öneri senaryoları için birim testleri ve öneri ekranı gezinme kontrolü.
- Eski Swift 6 derleyicisinde abonelik kontrolünün fonksiyon referansı kaynaklı derleme hatası giderildi.

## 1.1.0

- Yeni film şeridi monogramı, uygulama ikonu, marka yazısı ve GitHub kimliği.
- Keşfet için geniş afişli seçki, daha okunaklı kartlar, yüklenme ve boş durum ekranları.
- Listede metin arama, son eklenen/isim/kişisel puan sıralaması; görünüm seçiminin hatırlanması.
- Platformlarda arama ve yalnızca seçilenleri gösterme.
- Detay sayfasında daha esnek başlık, görünür puan seçenekleri ve içerik paylaşma.
- Türkçe İ/i ve ı/I eşleşmesi; yer imi simgesi ve sürekli görünen arama alanı düzeltildi.
- Katalog yenilemesi başarısız olursa mevcut sonuçlar korunur.
- Yayın seçenekleri alınamasa da özet ve oyuncular açılır; eski yayın verileri açıklanır.
- İçerik değiştirildiğinde eski tür isteğinin yeni ekranı ezmesi önlendi.
- Kaydedilen içeriğin çevrimdışı bilgileri güncellenir; görseller arka planda küçültülür, tekrar istekler birleştirilir.
- Veri kalıcılığı ve hata durumları için regresyon testleri; temel gezinme için arayüz testleri eklendi.
- Veri silme işlemi önceki açılıştan kalan geçici JSON dosyasını da kaldırır; arama geçmişinde büyük/küçük harf tekrarları birleştirilir.
- Büyük yazı boyutlarında liste başlıkları alt alta yerleşir ve boş durum içeriği kaydırılabilir.
