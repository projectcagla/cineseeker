"use client";

import { useState } from "react";
import Image from "next/image";
import { Check, Tv, Sparkles } from "lucide-react";
import { toggleUserSubscribedProvider } from "@/app/actions/providers";
import { useRouter } from "next/navigation";

export interface PlatformItem {
    providerId: number;
    providerName: string;
    logoPath: string;
}

interface PlatformsClientProps {
    allPlatforms: PlatformItem[];
    initialSubscribedIds: number[];
}

export function PlatformsClient({
    allPlatforms,
    initialSubscribedIds,
}: PlatformsClientProps) {
    const router = useRouter();
    const [subscribedIds, setSubscribedIds] = useState<number[]>(initialSubscribedIds);
    const [loadingId, setLoadingId] = useState<number | null>(null);

    const handleToggle = async (platform: PlatformItem) => {
        setLoadingId(platform.providerId);
        const isSubscribed = subscribedIds.includes(platform.providerId);

        // Optimistic update
        setSubscribedIds((prev) =>
            isSubscribed
                ? prev.filter((id) => id !== platform.providerId)
                : [...prev, platform.providerId]
        );

        const res = await toggleUserSubscribedProvider(platform);
        if (!res.success) {
            // Revert on error
            setSubscribedIds((prev) =>
                isSubscribed ? [...prev, platform.providerId] : prev.filter((id) => id !== platform.providerId)
            );
        } else {
            router.refresh();
        }
        setLoadingId(null);
    };

    return (
        <div className="max-w-4xl mx-auto space-y-8">
            <div className="space-y-2 border-b border-border/60 pb-6">
                <div className="flex items-center gap-2 text-primary font-semibold text-sm">
                    <Tv className="w-4 h-4" />
                    <span>Kişiselleştirme</span>
                </div>
                <h1 className="text-3xl font-bold tracking-tight">Platform Aboneliklerim</h1>
                <p className="text-muted-foreground text-sm max-w-2xl">
                    Kullandığınız yayın platformlarını seçin. Filmlerde abone olduğunuz servisler öncelikli ve vurgulu gösterilir.
                </p>
            </div>

            <div className="bg-primary/5 border border-primary/20 rounded-2xl p-4 md:p-6 flex items-start gap-4">
                <div className="p-2.5 rounded-xl bg-primary/10 text-primary shrink-0">
                    <Sparkles className="w-5 h-5" />
                </div>
                <div className="space-y-1">
                    <h2 className="font-semibold text-sm text-foreground">Akıllı Filtreleme Aktif</h2>
                    <p className="text-xs text-muted-foreground leading-relaxed">
                        Seçtiğiniz platformlar film kartlarında özel rozetlerle vurgulanacak. Ayrıca ana sayfada &quot;Sadece Platformlarım&quot; filtresini açarak ek abonelik gerektirmeyen filmleri tek tıkla listeleyebilirsiniz.
                    </p>
                </div>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                {allPlatforms.map((platform) => {
                    const isSubscribed = subscribedIds.includes(platform.providerId);
                    const isLoading = loadingId === platform.providerId;

                    return (
                        <button
                            key={platform.providerId}
                            onClick={() => handleToggle(platform)}
                            disabled={isLoading}
                            className={`group relative p-4 rounded-2xl border text-left transition-all duration-200 flex flex-col items-center justify-center text-center gap-3 ${
                                isSubscribed
                                    ? "bg-primary/10 border-primary shadow-md shadow-primary/5"
                                    : "bg-card border-border hover:border-border/80 hover:bg-muted/40"
                            } ${isLoading ? "opacity-70" : ""}`}
                        >
                            {/* Checkmark Badge */}
                            <div
                                className={`absolute top-2.5 right-2.5 w-5 h-5 rounded-full flex items-center justify-center transition-colors ${
                                    isSubscribed
                                        ? "bg-primary text-primary-foreground"
                                        : "bg-muted text-transparent group-hover:text-muted-foreground/40"
                                }`}
                            >
                                <Check className="w-3 h-3 stroke-[3]" />
                            </div>

                            {/* Logo */}
                            <div className="relative w-14 h-14 rounded-2xl overflow-hidden border border-white/10 shadow-md">
                                <Image
                                    src={`https://image.tmdb.org/t/p/original${platform.logoPath}`}
                                    alt={platform.providerName}
                                    fill
                                    className="object-cover"
                                    sizes="56px"
                                />
                            </div>

                            <div>
                                <h3 className="font-semibold text-sm line-clamp-1">{platform.providerName}</h3>
                                <p className="text-[11px] text-muted-foreground mt-0.5">
                                    {isSubscribed ? "Abonesiniz" : "Seçmek için tıkla"}
                                </p>
                            </div>
                        </button>
                    );
                })}
            </div>
        </div>
    );
}
