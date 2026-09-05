import Link from "next/link";
import Image from "next/image";

export function Footer() {
    return (
        <footer className="border-t border-white/5 bg-card/40 mt-20 text-sm text-muted-foreground">
            <div className="container mx-auto px-4 py-12 space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                    {/* Brand column */}
                    <div className="space-y-3 md:col-span-2">
                        <Link href="/" className="font-bold text-lg tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-primary to-orange-500 inline-block">
                            CINESEEKER
                        </Link>
                        <p className="text-xs text-muted-foreground leading-relaxed max-w-sm">
                            Türkiye&apos;deki yasal dijital yayın platformlarında hangi filmin nerede olduğunu anında öğrenin, kişisel izleme listenizi oluşturun ve aboneliklerinize göre filtreleyin.
                        </p>
                        <div className="flex items-center gap-2 pt-2 text-[11px] text-muted-foreground/80">
                            <span className="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                            <span>Cloudflare Edge Platform &bull; v0.7.2</span>
                        </div>
                    </div>

                    {/* Navigation */}
                    <div className="space-y-3">
                        <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">Hızlı Erişim</h4>
                        <ul className="space-y-2 text-xs">
                            <li>
                                <Link href="/" className="hover:text-foreground transition-colors">
                                    Ana Sayfa
                                </Link>
                            </li>
                            <li>
                                <Link href="/listem" className="hover:text-foreground transition-colors">
                                    İzleme Listem
                                </Link>
                            </li>
                            <li>
                                <Link href="/profil/platformlar" className="hover:text-foreground transition-colors">
                                    Aboneliklerim
                                </Link>
                            </li>
                            <li>
                                <Link href="/hesap" className="hover:text-foreground transition-colors">
                                    Hesap &amp; KVKK Veri Yönetimi
                                </Link>
                            </li>
                        </ul>
                    </div>

                    {/* Legal & Compliance */}
                    <div className="space-y-3">
                        <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">Yasal</h4>
                        <ul className="space-y-2 text-xs">
                            <li>
                                <Link href="/gizlilik" className="hover:text-foreground transition-colors">
                                    KVKK &amp; Gizlilik Politikası
                                </Link>
                            </li>
                            <li>
                                <Link href="/yasal" className="hover:text-foreground transition-colors">
                                    Kullanım Koşulları
                                </Link>
                            </li>
                        </ul>
                    </div>
                </div>

                {/* Attribution and Disclaimer Bar */}
                <div className="border-t border-white/5 pt-8 flex flex-col md:flex-row items-center justify-between gap-4 text-xs">
                    <div className="flex items-center gap-4">
                        <div className="relative w-20 h-6 shrink-0 opacity-80 hover:opacity-100 transition-opacity">
                            <Image
                                src="https://image.tmdb.org/t/p/original/wwemzKWzjKYJFfCeiB57q3r4Bcm.svg"
                                alt="The Movie Database (TMDB)"
                                fill
                                className="object-contain"
                            />
                        </div>
                        <p className="text-[11px] text-muted-foreground leading-tight">
                            Bu ürün TMDB API kullanmaktadır ancak TMDB tarafından onaylanmamış veya sertifikalandırılmamıştır. Yayın platformu verileri JustWatch iş birliğiyle sunulmaktadır.
                        </p>
                    </div>

                    <p className="text-[11px] text-muted-foreground/60 text-center md:text-right shrink-0">
                        &copy; {new Date().getFullYear()} CineSeeker. Tüm hakları saklıdır.
                    </p>
                </div>
            </div>
        </footer>
    );
}
