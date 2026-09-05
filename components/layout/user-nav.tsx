"use client";

import { useSession, signOut } from "@/lib/auth-client";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { User, Bookmark, Tv, LogOut } from "lucide-react";
import { useState, useRef, useEffect } from "react";

export function UserNav() {
    const router = useRouter();
    const { data: session, isPending } = useSession();
    const [dropdownOpen, setDropdownOpen] = useState(false);
    const dropdownRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        function handleClickOutside(event: MouseEvent) {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setDropdownOpen(false);
            }
        }
        document.addEventListener("mousedown", handleClickOutside);
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, []);

    if (isPending) {
        return <div className="w-20 h-9 bg-muted/40 rounded-lg animate-pulse" />;
    }

    if (!session) {
        return (
            <div className="flex items-center gap-2 shrink-0">
                <Link
                    href="/giris"
                    className="text-xs md:text-sm font-medium px-3 py-1.5 rounded-lg hover:bg-muted/50 transition-colors"
                >
                    Giriş Yap
                </Link>
                <Link
                    href="/kayit"
                    className="text-xs md:text-sm font-medium px-3 py-1.5 rounded-lg bg-primary hover:bg-primary/90 text-primary-foreground transition-colors"
                >
                    Kayıt Ol
                </Link>
            </div>
        );
    }

    return (
        <div className="relative shrink-0" ref={dropdownRef}>
            <button
                type="button"
                onClick={() => setDropdownOpen(!dropdownOpen)}
                className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-muted/40 hover:bg-muted/70 border border-white/5 transition-colors text-sm font-medium"
            >
                <div className="w-6 h-6 rounded-full bg-primary/20 text-primary flex items-center justify-center text-xs font-bold">
                    {session.user.name?.charAt(0).toUpperCase() || "U"}
                </div>
                <span className="hidden md:inline max-w-[120px] truncate">{session.user.name}</span>
            </button>

            {dropdownOpen && (
                <div className="absolute right-0 mt-2 w-56 bg-card border border-border rounded-xl shadow-xl py-2 z-50">
                    <div className="px-4 py-2 border-b border-border/50">
                        <p className="text-sm font-semibold truncate">{session.user.name}</p>
                        <p className="text-xs text-muted-foreground truncate">{session.user.email}</p>
                    </div>

                    <Link
                        href="/listem"
                        onClick={() => setDropdownOpen(false)}
                        className="flex items-center gap-2.5 px-4 py-2 text-sm text-foreground/80 hover:text-foreground hover:bg-muted/50 transition-colors"
                    >
                        <Bookmark className="w-4 h-4 text-muted-foreground" />
                        İzleme Listem
                    </Link>

                    <Link
                        href="/profil/platformlar"
                        onClick={() => setDropdownOpen(false)}
                        className="flex items-center gap-2.5 px-4 py-2 text-sm text-foreground/80 hover:text-foreground hover:bg-muted/50 transition-colors"
                    >
                        <Tv className="w-4 h-4 text-muted-foreground" />
                        Aboneliklerim
                    </Link>

                    <Link
                        href="/hesap"
                        onClick={() => setDropdownOpen(false)}
                        className="flex items-center gap-2.5 px-4 py-2 text-sm text-foreground/80 hover:text-foreground hover:bg-muted/50 transition-colors"
                    >
                        <User className="w-4 h-4 text-muted-foreground" />
                        Hesap Ayarları
                    </Link>

                    <div className="border-t border-border/50 my-1" />

                    <button
                        type="button"
                        onClick={async () => {
                            setDropdownOpen(false);
                            await signOut();
                            router.push("/");
                            router.refresh();
                        }}
                        className="w-full flex items-center gap-2.5 px-4 py-2 text-sm text-destructive hover:bg-destructive/10 transition-colors text-left"
                    >
                        <LogOut className="w-4 h-4" />
                        Çıkış Yap
                    </button>
                </div>
            )}
        </div>
    );
}
