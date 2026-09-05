"use client";

import { useState } from "react";
import { authClient } from "@/lib/auth-client";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { KeyRound, AlertCircle, CheckCircle2 } from "lucide-react";
import { Suspense } from "react";

function ResetPasswordForm() {
    const searchParams = useSearchParams();
    const token = searchParams.get("token");

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
    const [message, setMessage] = useState<string | null>(null);

    const handleRequest = async (e: React.FormEvent) => {
        e.preventDefault();
        setStatus("loading");
        setMessage(null);

        try {
            const res = await authClient.requestPasswordReset({
                email,
                redirectTo: `${window.location.origin}/sifre-sifirla`,
            });

            if (res.error) {
                setStatus("error");
                setMessage(res.error.message || "İşlem gerçekleştirilemedi.");
            } else {
                setStatus("success");
                setMessage("Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.");
            }
        } catch {
            setStatus("error");
            setMessage("Beklenmeyen bir hata oluştu.");
        }
    };

    const handleReset = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!token) return;

        setStatus("loading");
        setMessage(null);

        try {
            const res = await authClient.resetPassword({
                newPassword: password,
                token,
            });

            if (res.error) {
                setStatus("error");
                setMessage(res.error.message || "Şifre sıfırlanamadı.");
            } else {
                setStatus("success");
                setMessage("Şifreniz başarıyla güncellendi! Giriş yapabilirsiniz.");
            }
        } catch {
            setStatus("error");
            setMessage("Beklenmeyen bir hata oluştu.");
        }
    };

    return (
        <div className="max-w-md mx-auto py-12 px-4">
            <div className="bg-card border border-border rounded-2xl p-6 md:p-8 space-y-6 shadow-xl">
                <div className="space-y-2 text-center">
                    <h1 className="text-2xl font-bold tracking-tight">
                        {token ? "Yeni Şifre Belirle" : "Şifremi Unuttum"}
                    </h1>
                    <p className="text-sm text-muted-foreground">
                        {token
                            ? "Hesabınız için yeni ve güvenli bir şifre girin."
                            : "Kayıtlı e-posta adresinize bir sıfırlama bağlantısı göndereceğiz."}
                    </p>
                </div>

                {message && (
                    <div className={`p-4 rounded-xl text-sm flex items-center gap-2.5 ${
                        status === "success"
                            ? "bg-emerald-500/10 border border-emerald-500/20 text-emerald-300"
                            : "bg-destructive/10 border border-destructive/20 text-destructive"
                    }`}>
                        {status === "success" ? (
                            <CheckCircle2 className="w-5 h-5 shrink-0 text-emerald-400" />
                        ) : (
                            <AlertCircle className="w-5 h-5 shrink-0" />
                        )}
                        <span>{message}</span>
                    </div>
                )}

                {status === "success" && token ? (
                    <Link
                        href="/giris"
                        className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold rounded-xl text-sm transition-colors block text-center"
                    >
                        Giriş Yap
                    </Link>
                ) : (
                    <form onSubmit={token ? handleReset : handleRequest} className="space-y-4">
                        {token ? (
                            <div className="space-y-2">
                                <label className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                    Yeni Şifre
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
                        ) : (
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
                        )}

                        <button
                            type="submit"
                            disabled={status === "loading"}
                            className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold rounded-xl text-sm transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                        >
                            {status === "loading" ? "İşleniyor..." : (
                                <>
                                    <KeyRound className="w-4 h-4" />
                                    {token ? "Şifreyi Güncelle" : "Sıfırlama Bağlantısı Gönder"}
                                </>
                            )}
                        </button>
                    </form>
                )}

                <div className="border-t border-border/50 pt-4 text-center text-sm text-muted-foreground">
                    <Link href="/giris" className="font-semibold text-primary hover:underline">
                        Giriş Ekranına Dön
                    </Link>
                </div>
            </div>
        </div>
    );
}

export default function ResetPasswordPage() {
    return (
        <Suspense fallback={<div className="max-w-md mx-auto py-20 text-center text-muted-foreground">Yükleniyor...</div>}>
            <ResetPasswordForm />
        </Suspense>
    );
}
