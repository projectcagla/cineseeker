"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Star, Trash2, Clock, Eye, Check, Film } from "lucide-react";
import { removeFromWatchlist, updateWatchlistStatus, WatchlistStatus } from "@/app/actions/watchlist";
import { useRouter } from "next/navigation";

export interface WatchlistItemData {
    id: string;
    userId: string;
    tmdbId: number;
    mediaType: string;
    title: string;
    posterPath: string | null;
    voteAverage: string | null;
    releaseYear: string | null;
    status: string;
    rating: number | null;
    addedAt: Date;
    updatedAt: Date;
}

interface WatchlistClientProps {
    initialItems: WatchlistItemData[];
}

export function WatchlistClient({ initialItems }: WatchlistClientProps) {
    const router = useRouter();
    const [items, setItems] = useState<WatchlistItemData[]>(initialItems);
    const [activeTab, setActiveTab] = useState<"all" | WatchlistStatus>("all");
    const [loadingId, setLoadingId] = useState<number | null>(null);

    const filteredItems = items.filter((item) => {
        if (activeTab === "all") return true;
        return item.status === activeTab;
    });

    const counts = {
        all: items.length,
        want: items.filter((i) => i.status === "want").length,
        watching: items.filter((i) => i.status === "watching").length,
        watched: items.filter((i) => i.status === "watched").length,
    };

    const handleStatusChange = async (tmdbId: number, newStatus: WatchlistStatus) => {
        setLoadingId(tmdbId);
        const res = await updateWatchlistStatus(tmdbId, newStatus);
        if (res.success) {
            setItems((prev) =>
                prev.map((i) => (i.tmdbId === tmdbId ? { ...i, status: newStatus } : i))
            );
        }
        setLoadingId(null);
    };

    const handleRatingChange = async (tmdbId: number, newRating: number) => {
        const item = items.find((i) => i.tmdbId === tmdbId);
        if (!item) return;

        const updatedRating = item.rating === newRating ? null : newRating;
        setItems((prev) =>
            prev.map((i) => (i.tmdbId === tmdbId ? { ...i, rating: updatedRating } : i))
        );

        await updateWatchlistStatus(tmdbId, item.status as WatchlistStatus, updatedRating);
    };

    const handleRemove = async (tmdbId: number) => {
        setLoadingId(tmdbId);
        const res = await removeFromWatchlist(tmdbId);
        if (res.success) {
            setItems((prev) => prev.filter((i) => i.tmdbId !== tmdbId));
            router.refresh();
        }
        setLoadingId(null);
    };

    return (
        <div className="space-y-8">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-border/60 pb-6">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">İzleme Listem</h1>
                    <p className="text-sm text-muted-foreground mt-1">
                        Kaydettiğiniz filmler, izleme durumlarınız ve kişisel puanlarınız.
                    </p>
                </div>

                {/* Filter Tabs */}
                <div className="flex items-center gap-1.5 p-1 bg-muted/50 rounded-xl border border-border text-sm overflow-x-auto">
                    <button
                        onClick={() => setActiveTab("all")}
                        className={`px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap ${
                            activeTab === "all"
                                ? "bg-card text-foreground shadow-sm"
                                : "text-muted-foreground hover:text-foreground"
                        }`}
                    >
                        Tümü ({counts.all})
                    </button>
                    <button
                        onClick={() => setActiveTab("want")}
                        className={`px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap flex items-center gap-1.5 ${
                            activeTab === "want"
                                ? "bg-card text-foreground shadow-sm"
                                : "text-muted-foreground hover:text-foreground"
                        }`}
                    >
                        <Clock className="w-3.5 h-3.5" />
                        İzlenecekler ({counts.want})
                    </button>
                    <button
                        onClick={() => setActiveTab("watching")}
                        className={`px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap flex items-center gap-1.5 ${
                            activeTab === "watching"
                                ? "bg-card text-foreground shadow-sm"
                                : "text-muted-foreground hover:text-foreground"
                        }`}
                    >
                        <Eye className="w-3.5 h-3.5" />
                        İzliyorum ({counts.watching})
                    </button>
                    <button
                        onClick={() => setActiveTab("watched")}
                        className={`px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap flex items-center gap-1.5 ${
                            activeTab === "watched"
                                ? "bg-card text-foreground shadow-sm"
                                : "text-muted-foreground hover:text-foreground"
                        }`}
                    >
                        <Check className="w-3.5 h-3.5" />
                        İzlediklerim ({counts.watched})
                    </button>
                </div>
            </div>

            {filteredItems.length === 0 ? (
                <div className="text-center py-20 px-4 space-y-4 bg-card/40 border border-border/60 rounded-2xl">
                    <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-muted text-muted-foreground">
                        <Film className="w-7 h-7" />
                    </div>
                    <div className="space-y-1">
                        <h2 className="text-lg font-semibold">Bu sekmede henüz film yok</h2>
                        <p className="text-sm text-muted-foreground max-w-sm mx-auto">
                            Filmlerin afişlerindeki veya detay sayfalarındaki &quot;Listeme Ekle&quot; düğmesini kullanarak koleksiyonunuzu oluşturun.
                        </p>
                    </div>
                    <div className="pt-2">
                        <Link
                            href="/"
                            className="inline-flex items-center px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-xl text-sm hover:bg-primary/90 transition-colors"
                        >
                            Filmleri Keşfet
                        </Link>
                    </div>
                </div>
            ) : (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 md:gap-6">
                    {filteredItems.map((item) => (
                        <div
                            key={item.id}
                            className="group relative bg-card border border-border/80 rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 flex flex-col"
                        >
                            <Link href={`/movie/${item.tmdbId}`} className="block relative aspect-[2/3] bg-muted overflow-hidden">
                                {item.posterPath ? (
                                    <Image
                                        src={`https://image.tmdb.org/t/p/w500${item.posterPath}`}
                                        alt={item.title}
                                        fill
                                        className="object-cover group-hover:scale-105 transition-transform duration-300"
                                        sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 20vw"
                                    />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center text-muted-foreground text-xs">
                                        Afiş Yok
                                    </div>
                                )}

                                {/* Remove Button */}
                                <button
                                    onClick={(e) => {
                                        e.preventDefault();
                                        e.stopPropagation();
                                        handleRemove(item.tmdbId);
                                    }}
                                    disabled={loadingId === item.tmdbId}
                                    className="absolute top-2 right-2 p-1.5 rounded-lg bg-black/60 backdrop-blur-md text-white/80 hover:text-destructive hover:bg-black/90 transition-colors opacity-0 group-hover:opacity-100"
                                    title="Listeden Kaldır"
                                >
                                    <Trash2 className="w-3.5 h-3.5" />
                                </button>

                                {/* Personal Rating Badge */}
                                {item.rating && (
                                    <div className="absolute top-2 left-2 bg-black/70 backdrop-blur-md px-1.5 py-0.5 rounded-md flex items-center gap-1 text-xs font-semibold text-yellow-400 border border-yellow-500/30">
                                        <Star className="w-3 h-3 fill-yellow-400" />
                                        <span>{item.rating}/10</span>
                                    </div>
                                )}
                            </Link>

                            <div className="p-3 flex-1 flex flex-col justify-between space-y-2.5">
                                <div>
                                    <Link href={`/movie/${item.tmdbId}`} className="hover:text-primary transition-colors">
                                        <h3 className="font-semibold text-sm line-clamp-1 leading-tight">{item.title}</h3>
                                    </Link>
                                    <div className="flex items-center gap-2 text-xs text-muted-foreground mt-0.5">
                                        {item.releaseYear && <span>{item.releaseYear}</span>}
                                        {item.voteAverage && (
                                            <span className="flex items-center gap-0.5">
                                                <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                                                {parseFloat(item.voteAverage).toFixed(1)}
                                            </span>
                                        )}
                                    </div>
                                </div>

                                {/* Status Select */}
                                <div className="space-y-1.5 pt-2 border-t border-border/60">
                                    <select
                                        value={item.status}
                                        onChange={(e) => handleStatusChange(item.tmdbId, e.target.value as WatchlistStatus)}
                                        disabled={loadingId === item.tmdbId}
                                        className="w-full text-xs font-medium py-1.5 px-2 bg-muted/50 hover:bg-muted border border-border rounded-lg text-foreground focus:outline-none focus:ring-1 focus:ring-primary transition-colors"
                                    >
                                        <option value="want">İzleyeceğim</option>
                                        <option value="watching">İzliyorum</option>
                                        <option value="watched">İzledim</option>
                                    </select>

                                    {/* Star Rating Bar */}
                                    <div className="flex items-center justify-between pt-1">
                                        {[2, 4, 6, 8, 10].map((starVal) => (
                                            <button
                                                key={starVal}
                                                onClick={() => handleRatingChange(item.tmdbId, starVal)}
                                                className="p-0.5 hover:scale-110 transition-transform"
                                                title={`${starVal}/10 puan ver`}
                                            >
                                                <Star
                                                    className={`w-3 h-3 ${
                                                        item.rating && item.rating >= starVal
                                                            ? "text-yellow-500 fill-yellow-500"
                                                            : "text-muted-foreground/30 hover:text-yellow-400"
                                                    }`}
                                                />
                                            </button>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
