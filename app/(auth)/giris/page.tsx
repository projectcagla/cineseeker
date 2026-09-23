"use client";

import { useState } from "react";
import { signIn } from "@/lib/auth-client";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { LogIn, AlertCircle } from "lucide-react";
import { Suspense } from "react";

function LoginForm() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const nextUrl = searchParams.get("next") || "/";

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);
        setLoading(true);

        try {
            const res = await signIn.email({
                email,
                password,
            });

            if (res.error) {
                setError(res.error.message || "Giriş yapılamadı. Bilgilerinizi kontrol edin.");
            } else {
                router.push(nextUrl);
                router.refresh();
            }
        } catch {
            setError("Giriş sırasında beklenmeyen bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="max-w-md mx-auto py-12 px-4">
            <div className="bg-card border border-border rounded-2xl p-6 md:p-8 space-y-6 shadow-xl">
                <div className="space-y-2 text-center">
                    <h1 className="text-2xl font-bold tracking-tight">Giriş Yap</h1>
                    <p className="text-sm text-muted-foreground">
                        İzleme listenizi ve abone olduğunuz platformları yönetin.
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
                        <div className="flex items-center justify-between">
                            <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                Şifre
                            </label>
                            <Link href="/sifre-sifirla" className="text-xs text-primary hover:underline">
                                Şifremi Unuttum
                            </Link>
                        </div>
                        <input
                            type="password"
                            required
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="••••••••"
                            className="w-full px-4 py-2.5 bg-muted/40 border border-border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold rounded-xl text-sm transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                    >
                        {loading ? "Giriş yapılıyor..." : (
                            <>
                                <LogIn className="w-4 h-4" />
                                Giriş Yap
                            </>
                        )}
                    </button>
                </form>

                <div className="border-t border-border/50 pt-4 text-center text-sm text-muted-foreground">
                    Hesabınız yok mu?{" "}
                    <Link href="/kayit" className="font-semibold text-primary hover:underline">
                        Ücretsiz Kayıt Olun
                    </Link>
                </div>
            </div>
        </div>
    );
}

export default function LoginPage() {
    return (
        <Suspense fallback={<div className="max-w-md mx-auto py-20 text-center text-muted-foreground">Yükleniyor...</div>}>
            <LoginForm />
        </Suspense>
    );
}
