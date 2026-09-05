import { Metadata } from "next";
import Link from "next/link";
import { ShieldCheck, Database, Lock, Download, Trash2, ArrowLeft } from "lucide-react";

export const metadata: Metadata = {
    title: "KVKK Aydınlatma Metni & Gizlilik Politikası | CineSeeker",
    description: "CineSeeker kişisel veri koruma, KVKK hakları ve gizlilik ilkeleri.",
};

export default function PrivacyPage() {
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
                    <ShieldCheck className="w-4 h-4" />
                    <span>KVKK Uyum Beyanı</span>
                </div>
                <h1 className="text-3xl font-bold tracking-tight">KVKK Aydınlatma Metni ve Gizlilik Politikası</h1>
                <p className="text-sm text-muted-foreground">
                    Son güncelleme: 5 Eylül 2026 &bull; Sürüm 0.7.2
                </p>
            </div>

            <div className="space-y-8 text-sm leading-relaxed text-foreground/90">
                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground flex items-center gap-2">
                        1. Veri Sorumlusu ve Genel Bakış
                    </h2>
                    <p className="text-muted-foreground">
                        6698 sayılı Kişisel Verilerin Korunması Kanunu (&quot;KVKK&quot;) kapsamında CineSeeker olarak, kullanıcılarımızın kişisel verilerinin güvenliğine ve gizliliğine azami hassasiyet göstermekteyiz. CineSeeker, film arama, nerede izleneceğini bulma, kişisel izleme listesi tutma ve platform abonelik tercihlerini kaydetme hizmetleri sunan bir dijital platformdur.
                    </p>
                </section>

                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground flex items-center gap-2">
                        <Lock className="w-4 h-4 text-primary" />
                        2. İşlenen Kişisel Veriler ve Amaçları
                    </h2>
                    <p className="text-muted-foreground">
                        CineSeeker üzerinde hesap oluşturduğunuzda yalnızca hizmetin işleyişi için zorunlu olan asgari veri işlenir:
                    </p>
                    <ul className="list-disc pl-5 space-y-2 text-muted-foreground">
                        <li>
                            <strong className="text-foreground">Kimlik &amp; İletişim Bilgileri:</strong> Ad-soyad ve e-posta adresi. Hesabınızı oluşturmak, kimliğinizi doğrulamak ve şifre sıfırlama işlemlerini gerçekleştirmek amacıyla kullanılır.
                        </li>
                        <li>
                            <strong className="text-foreground">Güvenlik Bilgileri:</strong> Şifreniz asla açık metin olarak saklanmaz. Endüstri standardı tek yönlü özetleme (cryptographic hash) algoritmalarıyla şifrelenmiş olarak saklanır.
                        </li>
                        <li>
                            <strong className="text-foreground">Kullanıcı Tercihleri:</strong> İzleme listenize eklediğiniz filmler, izleme durumlarınız (izleyeceğim, izliyorum, izledim), kişisel yıldız puanlarınız ve işaretlediğiniz abone olduğunuz yayın platformları (Netflix, Prime, vb.).
                        </li>
                    </ul>
                </section>

                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground flex items-center gap-2">
                        <Database className="w-4 h-4 text-primary" />
                        3. Verilerin Saklandığı Konum ve Altyapı Güvenliği
                    </h2>
                    <p className="text-muted-foreground">
                        CineSeeker, sunucusuz Cloudflare Workers platformu üzerinde çalışmakta ve veritabanı olarak Cloudflare D1 kullanmaktadır. Verileriniz Avrupa Birliği (AB) sınırları dahilindeki veri merkezlerinde (Batı Avrupa / WEUR bölgesi), aktarım sırasında TLS 1.3 ve beklemede AES-256 standartlarında şifrelenmiş olarak muhafaza edilmektedir.
                    </p>
                    <p className="text-muted-foreground">
                        Kişisel verileriniz hiçbir surette üçüncü taraf reklam ağlarına, pazarlama şirketlerine veya veri simsarlarına satılmaz veya kiralanmaz.
                    </p>
                </section>

                <section className="space-y-4">
                    <h2 className="text-lg font-semibold text-foreground flex items-center gap-2">
                        <Download className="w-4 h-4 text-primary" />
                        4. KVKK 11. Madde Kapsamındaki Haklarınız ve Otomasyon
                    </h2>
                    <p className="text-muted-foreground">
                        KVKK&apos;nın 11. maddesi uyarınca veri sahipleri kişisel verilerine erişme, düzeltilmesini talep etme, bir kopyasını alma ve silinmesini isteme hakkına sahiptir. CineSeeker, bu yasal haklarınızı beklemeden, anında ve doğrudan arayüzden kullanabilmeniz için self-servis araçlar geliştirmiştir:
                    </p>

                    <div className="grid sm:grid-cols-2 gap-4 pt-2">
                        <div className="p-4 rounded-xl border border-border bg-card space-y-2">
                            <div className="flex items-center gap-2 font-semibold text-foreground">
                                <Download className="w-4 h-4 text-primary" />
                                <span>Veri Taşınabilirliği (Export)</span>
                            </div>
                            <p className="text-xs text-muted-foreground">
                                <Link href="/hesap" className="text-primary hover:underline font-medium">Hesap Ayarları</Link> sayfasından &quot;Tüm Verilerimi İndir&quot; butonuna basarak profilinizi, izleme listenizi ve kayıtlı platform tercihlerinizi tek tıkla standart JSON formatında indirebilirsiniz.
                            </p>
                        </div>

                        <div className="p-4 rounded-xl border border-destructive/20 bg-destructive/5 space-y-2">
                            <div className="flex items-center gap-2 font-semibold text-destructive">
                                <Trash2 className="w-4 h-4" />
                                <span>Unutulma Hakkı (Hesap Silme)</span>
                            </div>
                            <p className="text-xs text-muted-foreground">
                                <Link href="/hesap" className="text-primary hover:underline font-medium">Hesap Ayarları</Link> sayfasından hesabınızı sildiğinizde, kullanıcınıza ait tüm oturumlar, profil bilgileri, izleme listeleri ve abonelik seçimleri D1 veritabanından kalıcı ve geri döndürülemez olarak silinir (Cascade Delete).
                            </p>
                        </div>
                    </div>
                </section>

                <section className="space-y-3">
                    <h2 className="text-lg font-semibold text-foreground">5. İletişim ve Veri Sahibi Başvurusu</h2>
                    <p className="text-muted-foreground">
                        KVKK ve kişisel verilerinizin işlenmesine dair her türlü soru, görüş ve başvurularınız için bizimle iletişime geçebilirsiniz.
                    </p>
                </section>
            </div>
        </div>
    );
}
