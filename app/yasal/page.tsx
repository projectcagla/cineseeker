import { Metadata } from "next";
import Link from "next/link";
import Image from "next/image";
import { FileText, ArrowLeft } from "lucide-react";

export const metadata: Metadata = {
    title: "Kullanım Koşulları & Yasal Uyarı | CineSeeker",
    description: "CineSeeker kullanım şartları, telif hakları ve TMDB/JustWatch yasal atıfları.",
};

export default function TermsPage() {
    return (
        <div className="max-w-3xl mx-auto py-8 space-y-10">
            <Link
                href="/"
                className="inline-flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors"
            >
                <ArrowLeft className="w-3.5 h-3.5" />
                Ana Sayfaya Dön
            </Link>

            <div className="space-y-3 border-b border-border/60 pb-6">
                <div className="flex items-center gap-2 text-primary text-sm font-semibold">
                    <FileText className="w-4 h-4" />
                    <span>Yasal Bildirimler</span>
                </div>
                <h1 className="text-3xl font-bold tracking-tight">Kullanım Koşulları ve Yasal Uyarı</h1>
                <p className="text-sm text-muted-foreground">
                    Son güncelleme: 5 Eylül 2026 &bull; Sürüm 0.7.2
                </p>
            </div>

            <div className="space-y-8 text-sm leading-relaxed text-foreground/90">
                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground">1. Hizmetin Niteliği ve Kapsamı</h2>
                    <p className="text-muted-foreground">
                        CineSeeker, sinema ve dizi severlere yönelik bir meta-arama ve bilgilendirme rehberidir. Platformumuzun temel amacı, Türkiye&apos;de yasal olarak faaliyet gösteren dijital yayın platformlarında (Netflix, Amazon Prime Video, Disney+, BluTV, TOD, Gain, MUBI, TV+ vb.) hangi içeriğin hangi yöntemle (abonelik, kiralama, satın alma) erişilebilir olduğunu listelemektir.
                    </p>
                    <div className="p-4 rounded-xl border border-amber-500/20 bg-amber-500/5 text-amber-300 text-xs leading-relaxed">
                        <strong>ÖNEMLİ BİLGİLENDİRME:</strong> CineSeeker, bir video barındırma, depolama ya da korsan yayın platformu değildir. Sunucularımızda hiçbir video dosyası tutulmamakta ve oynatılmamaktadır. Tüm yönlendirmeler yalnızca yasal hak sahiplerinin lisanslı servislerine işaret eder.
                    </div>
                </section>

                <section className="space-y-4">
                    <h2 className="text-lg font-semibold text-foreground">2. TMDB ve JustWatch Yasal Atıfları</h2>
                    <div className="p-5 rounded-xl border border-border bg-card space-y-4">
                        <div className="flex items-center gap-4">
                            <div className="relative w-24 h-8 shrink-0">
                                <Image
                                    src="https://image.tmdb.org/t/p/original/wwemzKWzjKYJFfCeiB57q3r4Bcm.svg"
                                    alt="TMDB Logo"
                                    fill
                                    className="object-contain"
                                />
                            </div>
                            <div className="text-xs text-muted-foreground">
                                <p className="font-semibold text-foreground">The Movie Database (TMDB)</p>
                                <p className="mt-0.5">
                                    &quot;This product uses the TMDB API but is not endorsed or certified by TMDB.&quot;
                                </p>
                            </div>
                        </div>

                        <p className="text-xs text-muted-foreground pt-2 border-t border-border">
                            Film afişleri, özetler, yönetmen/oyuncu künyeleri ve teknik detaylar TMDB API aracılığıyla sağlanmaktadır. Platform yayın akışı bilgileri (Watch Providers) TMDB ve JustWatch iş birliğiyle lisanslanmış verilerden oluşur.
                        </p>
                    </div>
                </section>

                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground">3. Telif Hakları ve Fikri Mülkiyet</h2>
                    <p className="text-muted-foreground">
                        Sitemizde sergilenen film adları, afişler, logolar ve ticari markalar ilgili yapım şirketlerinin ve platformların (örneğin Netflix Inc., Amazon.com Inc., The Walt Disney Company vb.) mülkiyetindedir. CineSeeker bu markalar üzerinde hak iddia etmez; materyaller bilgilendirme ve adil kullanım (fair use) kapsamında sunulur.
                    </p>
                </section>

                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground">4. Sorumluluğun Sınırlandırılması</h2>
                    <p className="text-muted-foreground">
                        Yayın platformlarının içerik katalogları ve fiyatlandırma politikaları dinamik olarak değişebilir. CineSeeker, platformlardaki anlık katalog değişiklikleri nedeniyle ortaya çıkabilecek uyuşmazlıklardan sorumlu tutulamaz. Kullanıcılar bir içeriği kiralamadan veya abone olmadan önce ilgili platformun güncel koşullarını kontrol etmekle yükümlüdür.
                    </p>
                </section>

                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground">5. Değişiklikler</h2>
                    <p className="text-muted-foreground">
                        CineSeeker, işbu kullanım koşullarını günün şartlarına ve mevzuat değişikliklerine uygun olarak dilediği zaman güncelleme hakkını saklı tutar.
                    </p>
                </section>
            </div>
        </div>
    );
}
