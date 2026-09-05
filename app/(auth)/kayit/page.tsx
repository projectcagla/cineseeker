"use client";

import { useState } from "react";
import { signUp } from "@/lib/auth-client";
import Link from "next/link";
import { UserPlus, AlertCircle, CheckCircle2 } from "lucide-react";

export default function RegisterPage() {
    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [termsAccepted, setTermsAccepted] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState(false);
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);

        if (!termsAccepted) {
            setError("Lütfen kullanıcı sözleşmesi ve aydınlatma metnini onaylayın.");
            return;
        }

        if (password.length < 8) {
            setError("Şifreniz en az 8 karakter olmalıdır.");
            return;
        }

        setLoading(true);

        try {
            const res = await signUp.email({
                name,
                email,
                password,
            });

            if (res.error) {
                setError(res.error.message || "Kayıt işlemi başarısız oldu.");
            } else {
                setSuccess(true);
            }
        } catch {
            setError("Kayıt sırasında beklenmeyen bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    };

    if (success) {
        return (
            <div className="max-w-md mx-auto py-16 px-4">
                <div className="bg-card border border-border rounded-2xl p-8 space-y-6 text-center shadow-xl">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-emerald-500/10 text-emerald-400 mx-auto">
                        <CheckCircle2 className="w-8 h-8" />
                    </div>
                    <div className="space-y-2">
                        <h1 className="text-2xl font-bold">Kayıt Başarılı!</h1>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            <span className="font-semibold text-foreground">{email}</span> adresine bir doğrulama bağlantısı gönderdik. Lütfen e-postanızı kontrol ederek hesabınızı aktifleştirin.
                        </p>
                    </div>
                    <div className="pt-4">
                        <Link href="/giris" className="inline-flex items-center justify-center w-full py-3 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold rounded-xl text-sm transition-colors">
                            Giriş Sayfasına Git
                        </Link>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="max-w-md mx-auto py-12 px-4">
            <div className="bg-card border border-border rounded-2xl p-6 md:p-8 space-y-6 shadow-xl">
                <div className="space-y-2 text-center">
                    <h1 className="text-2xl font-bold tracking-tight">Hesap Oluştur</h1>
                    <p className="text-sm text-muted-foreground">
                        CineSeeker ile Türkiye&apos;deki tüm yayın platformlarını kişiselleştirin.
                    </p>
                </div>

                {error && (
                    <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-xl text-destructive text-sm flex items-center gap-2">
                        <AlertCircle className="w-4 h-4 shrink-0" />
                        <span>{error}</span>
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="space-y-2">
                        <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                            Ad Soyad
                        </label>
                        <input
                            type="text"
                            required
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            placeholder="Adınız Soyadınız"
                            className="w-full px-4 py-2.5 bg-muted/40 border border-border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all"
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                            E-posta Adresi
                        </label>
                        <input
                            type="email"
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="ornek@posta.com"
                            className="w-full px-4 py-2.5 bg-muted/40 border border-border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all"
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                            Şifre (En az 8 karakter)
                        </label>
                        <input
                            type="password"
                            required
                            minLength={8}
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="••••••••"
                            className="w-full px-4 py-2.5 bg-muted/40 border border-border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all"
                        />
                    </div>

                    <div className="flex items-start gap-2.5 pt-2">
                        <input
                            type="checkbox"
                            id="terms"
                            checked={termsAccepted}
                            onChange={(e) => setTermsAccepted(e.target.checked)}
                            className="mt-1 h-4 w-4 rounded border-border bg-muted/40 text-primary focus:ring-primary"
                        />
                        <label htmlFor="terms" className="text-xs text-muted-foreground leading-relaxed">
                            <Link href="/yasal" className="text-foreground underline hover:text-primary">
                                Kullanım Koşulları
                            </Link>
                            &apos;nı ve{" "}
                            <Link href="/gizlilik" className="text-foreground underline hover:text-primary">
                                KVKK Aydınlatma Metni
                            </Link>
                            &apos;ni okudum, kabul ediyorum.
                        </label>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold rounded-xl text-sm transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                    >
                        {loading ? "Hesap oluşturuluyor..." : (
                            <>
                                <UserPlus className="w-4 h-4" />
                                Ücretsiz Kayıt Ol
                            </>
                        )}
                    </button>
                </form>

                <div className="border-t border-border/50 pt-4 text-center text-sm text-muted-foreground">
                    Zaten hesabınız var mı?{" "}
                    <Link href="/giris" className="font-semibold text-primary hover:underline">
                        Giriş Yapın
                    </Link>
                </div>
            </div>
        </div>
    );
}
