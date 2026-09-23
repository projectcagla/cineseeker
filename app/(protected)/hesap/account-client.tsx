"use client";

import { useState } from "react";
import { signOut } from "@/lib/auth-client";
import { useRouter } from "next/navigation";
import { Download, Trash2, AlertTriangle, CheckCircle2 } from "lucide-react";

interface AccountClientProps {
    user: {
        id: string;
        name: string;
        email: string;
        emailVerified: boolean;
        createdAt: Date;
    };
}

export function AccountClient({ user }: AccountClientProps) {
    const router = useRouter();
    const [deleting, setDeleting] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [deleteConfirmText, setDeleteConfirmText] = useState("");

    const handleDeleteAccount = async () => {
        if (deleteConfirmText !== "HESABIMI SİL") return;
        setDeleting(true);

        try {
            const res = await fetch("/api/user/delete", { method: "POST" });
            if (res.ok) {
                await signOut();
                router.push("/");
                router.refresh();
            } else {
                alert("Hesap silinirken bir hata oluştu.");
            }
        } catch {
            alert("Sunucuya bağlanılamadı.");
        } finally {
            setDeleting(false);
        }
    };

    return (
        <div className="max-w-2xl mx-auto py-8 px-4 space-y-8">
            <div className="space-y-1">
                <h1 className="text-3xl font-bold tracking-tight">Hesap Ayarları</h1>
                <p className="text-sm text-muted-foreground">Kişisel bilgilerinizi ve veri haklarınızı yönetin.</p>
            </div>

            {/* Profile Info */}
            <div className="bg-card border border-border rounded-2xl p-6 space-y-4">
                <h2 className="text-lg font-bold border-b border-border/50 pb-3">Profil Bilgileri</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                    <div>
                        <span className="text-muted-foreground block text-xs uppercase tracking-wider mb-1">Ad Soyad</span>
                        <span className="font-semibold text-foreground">{user.name}</span>
                    </div>
                    <div>
                        <span className="text-muted-foreground block text-xs uppercase tracking-wider mb-1">E-posta Adresi</span>
                        <div className="flex items-center gap-2">
                            <span className="font-semibold text-foreground">{user.email}</span>
                            {user.emailVerified ? (
                                <span className="inline-flex items-center gap-1 text-[11px] font-medium text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full">
                                    <CheckCircle2 className="w-3 h-3" /> Doğrulandı
                                </span>
                            ) : (
                                <span className="text-[11px] font-medium text-amber-400 bg-amber-500/10 px-2 py-0.5 rounded-full">
                                    Doğrulanmadı
                                </span>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            {/* Privacy & KVKK / GDPR Data Rights */}
            <div className="bg-card border border-border rounded-2xl p-6 space-y-4">
                <h2 className="text-lg font-bold border-b border-border/50 pb-3">Kişisel Verileriniz (KVKK & GDPR)</h2>
                <p className="text-sm text-muted-foreground leading-relaxed">
                    6698 sayılı Kişisel Verilerin Korunması Kanunu ve GDPR uyarınca, hesabınızda saklanan tüm verileri dilediğiniz zaman makine tarafından okunabilir JSON formatında indirebilirsiniz.
                </p>
                <div>
                    <a
                        href="/api/user/export"
                        download
                        className="inline-flex items-center gap-2 px-4 py-2.5 bg-muted hover:bg-muted/80 text-foreground font-medium rounded-xl text-sm transition-colors border border-border"
                    >
                        <Download className="w-4 h-4" />
                        Tüm Verilerimi İndir (JSON)
                    </a>
                </div>
            </div>

            {/* Danger Zone */}
            <div className="bg-destructive/5 border border-destructive/20 rounded-2xl p-6 space-y-4">
                <h2 className="text-lg font-bold text-destructive border-b border-destructive/10 pb-3 flex items-center gap-2">
                    <AlertTriangle className="w-5 h-5" />
                    Tehlikeli Bölge
                </h2>
                <p className="text-sm text-muted-foreground leading-relaxed">
                    Hesabınızı sildiğinizde, izleme listeniz, abonelik tercihleriniz ve tüm kişisel verileriniz veritabanından kalıcı olarak silinir. Bu işlem geri alınamaz.
                </p>
                <button
                    type="button"
                    onClick={() => setShowDeleteModal(true)}
                    className="inline-flex items-center gap-2 px-4 py-2.5 bg-destructive hover:bg-destructive/90 text-destructive-foreground font-semibold rounded-xl text-sm transition-colors"
                >
                    <Trash2 className="w-4 h-4" />
                    Hesabımı Kalıcı Olarak Sil
                </button>
            </div>

            {/* Delete Modal */}
            {showDeleteModal && (
                <div className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm flex items-center justify-center p-4">
                    <div className="bg-card border border-border rounded-2xl p-6 max-w-md w-full space-y-4 shadow-2xl animate-in fade-in zoom-in-95 duration-150">
                        <div className="flex items-center gap-2 text-destructive">
                            <AlertTriangle className="w-6 h-6" />
                            <h3 className="text-lg font-bold">Hesabınızı Silmek Üzeresiniz</h3>
                        </div>
                        <p className="text-sm text-muted-foreground leading-relaxed">
                            Bu işlem geri alınamaz. Onaylamak için lütfen aşağıdaki kutuya büyük harflerle{" "}
                            <span className="font-bold text-foreground">HESABIMI SİL</span> yazınız:
                        </p>
                        <input
                            type="text"
                            value={deleteConfirmText}
                            onChange={(e) => setDeleteConfirmText(e.target.value)}
                            placeholder="HESABIMI SİL"
                            className="w-full px-4 py-2.5 bg-muted/40 border border-border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-destructive/50"
                        />
                        <div className="flex items-center justify-end gap-3 pt-2">
                            <button
                                type="button"
                                onClick={() => {
                                    setShowDeleteModal(false);
                                    setDeleteConfirmText("");
                                }}
                                className="px-4 py-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                            >
                                İptal
                            </button>
                            <button
                                type="button"
                                disabled={deleteConfirmText !== "HESABIMI SİL" || deleting}
                                onClick={handleDeleteAccount}
                                className="px-4 py-2 bg-destructive hover:bg-destructive/90 text-destructive-foreground font-semibold rounded-xl text-sm transition-colors disabled:opacity-50"
                            >
                                {deleting ? "Siliniyor..." : "Evet, Hesabımı Sil"}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
