"use client";

import { useState } from "react";
import { Bookmark, Check, Clock, Eye, Star, Trash2 } from "lucide-react";
import { addToWatchlist, removeFromWatchlist, updateWatchlistStatus, WatchlistStatus } from "@/app/actions/watchlist";
import { useRouter } from "next/navigation";

interface WatchlistButtonProps {
    movieId: number;
    title: string;
    posterPath?: string | null;
    voteAverage?: string | null;
    releaseYear?: string | null;
    initialStatus?: WatchlistStatus | null;
    initialRating?: number | null;
    variant?: "compact" | "full";
    className?: string;
}

export function WatchlistButton({
    movieId,
    title,
    posterPath,
    voteAverage,
    releaseYear,
    initialStatus = null,
    initialRating = null,
    variant = "full",
    className = "",
}: WatchlistButtonProps) {
    const router = useRouter();
    const [status, setStatus] = useState<WatchlistStatus | null>(initialStatus);
    const [rating, setRating] = useState<number | null>(initialRating);
    const [isOpen, setIsOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const handleQuickToggle = async (e: React.MouseEvent) => {
        e.preventDefault();
        e.stopPropagation();

        if (loading) return;
        setLoading(true);

        if (status) {
            // Remove
            const res = await removeFromWatchlist(movieId);
            if (res.success) {
                setStatus(null);
                setRating(null);
            } else if (res.error?.includes("giriş")) {
                router.push("/giris");
            }
        } else {
            // Add as 'want'
            const res = await addToWatchlist({
                tmdbId: movieId,
                mediaType: "movie",
                title,
                posterPath,
                voteAverage,
                releaseYear,
                status: "want",
            });
            if (res.success) {
                setStatus("want");
            } else if (res.error?.includes("giriş")) {
                router.push("/giris");
            }
        }
        setLoading(false);
    };

    const handleSetStatus = async (newStatus: WatchlistStatus) => {
        if (loading) return;
        setLoading(true);

        if (!status) {
            const res = await addToWatchlist({
                tmdbId: movieId,
                mediaType: "movie",
                title,
                posterPath,
                voteAverage,
                releaseYear,
                status: newStatus,
                rating,
            });
            if (res.success) {
                setStatus(newStatus);
            } else if (res.error?.includes("giriş")) {
                router.push("/giris");
            }
        } else {
            const res = await updateWatchlistStatus(movieId, newStatus, rating);
            if (res.success) {
                setStatus(newStatus);
            }
        }

        setIsOpen(false);
        setLoading(false);
    };

    const handleSetRating = async (newRating: number) => {
        const targetRating = rating === newRating ? null : newRating;
        setRating(targetRating);

        if (status) {
            await updateWatchlistStatus(movieId, status, targetRating);
        } else {
            const res = await addToWatchlist({
                tmdbId: movieId,
                mediaType: "movie",
                title,
                posterPath,
                voteAverage,
                releaseYear,
                status: "watched",
                rating: targetRating,
            });
            if (res.success) {
                setStatus("watched");
            }
        }
    };

    const handleRemove = async () => {
        if (loading) return;
        setLoading(true);
        const res = await removeFromWatchlist(movieId);
        if (res.success) {
            setStatus(null);
            setRating(null);
        }
        setIsOpen(false);
        setLoading(false);
    };

    if (variant === "compact") {
        return (
            <button
                onClick={handleQuickToggle}
                disabled={loading}
                aria-label={status ? "Listeden Çıkar" : "Listeye Ekle"}
                className={`p-2 rounded-full backdrop-blur-md transition-all shadow-md ${
                    status
                        ? "bg-primary text-primary-foreground hover:bg-primary/90"
                        : "bg-black/60 text-white/80 hover:text-white hover:bg-black/80"
                } ${className}`}
            >
                <Bookmark className={`w-3.5 h-3.5 ${status ? "fill-current" : ""}`} />
            </button>
        );
    }

    return (
        <div className={`relative inline-block text-left ${className}`}>
            <div className="flex items-center gap-2">
                <button
                    onClick={status ? () => setIsOpen(!isOpen) : handleQuickToggle}
                    disabled={loading}
                    className={`inline-flex items-center gap-2 px-4 py-2.5 rounded-xl font-medium text-sm transition-all border shadow-lg ${
                        status
                            ? "bg-primary/20 border-primary/40 text-primary hover:bg-primary/30"
                            : "bg-card/80 backdrop-blur-md border-border text-foreground hover:bg-muted"
                    }`}
                >
                    <Bookmark className={`w-4 h-4 ${status ? "fill-primary" : ""}`} />
                    <span>
                        {status === "want" && "İzlenecekler Listemde"}
                        {status === "watching" && "Şu An İzliyorum"}
                        {status === "watched" && "İzlediklerimde"}
                        {!status && "Listeme Ekle"}
                    </span>
                </button>

                {status && (
                    <button
                        onClick={() => setIsOpen(!isOpen)}
                        className="p-2.5 rounded-xl border border-border bg-card/80 backdrop-blur-md hover:bg-muted text-muted-foreground hover:text-foreground transition-all"
                        aria-label="Listeyi Düzenle"
                    >
                        <Eye className="w-4 h-4" />
                    </button>
                )}
            </div>

            {isOpen && (
                <>
                    <div
                        className="fixed inset-0 z-40"
                        onClick={() => setIsOpen(false)}
                    />
                    <div className="absolute left-0 mt-2 w-64 rounded-2xl bg-card border border-border p-3 shadow-2xl z-50 space-y-3 animate-in fade-in zoom-in-95 duration-150">
                        <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wider px-2">
                            İzleme Durumu
                        </div>

                        <div className="space-y-1">
                            <button
                                onClick={() => handleSetStatus("want")}
                                className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm transition-colors ${
                                    status === "want"
                                        ? "bg-primary/20 text-primary font-medium"
                                        : "hover:bg-muted text-foreground"
                                }`}
                            >
                                <span className="flex items-center gap-2">
                                    <Clock className="w-4 h-4" />
                                    İzlemek İstiyorum
                                </span>
                                {status === "want" && <Check className="w-4 h-4" />}
                            </button>

                            <button
                                onClick={() => handleSetStatus("watching")}
                                className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm transition-colors ${
                                    status === "watching"
                                        ? "bg-primary/20 text-primary font-medium"
                                        : "hover:bg-muted text-foreground"
                                }`}
                            >
                                <span className="flex items-center gap-2">
                                    <Eye className="w-4 h-4" />
                                    İzliyorum
                                </span>
                                {status === "watching" && <Check className="w-4 h-4" />}
                            </button>

                            <button
                                onClick={() => handleSetStatus("watched")}
                                className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm transition-colors ${
                                    status === "watched"
                                        ? "bg-primary/20 text-primary font-medium"
                                        : "hover:bg-muted text-foreground"
                                }`}
                            >
                                <span className="flex items-center gap-2">
                                    <Check className="w-4 h-4" />
                                    İzledim
                                </span>
                                {status === "watched" && <Check className="w-4 h-4" />}
                            </button>
                        </div>

                        {/* Rating section */}
                        <div className="border-t border-border pt-2 space-y-1.5 px-2">
                            <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                                Puanım: {rating ? `${rating}/10` : "Puan Ver"}
                            </div>
                            <div className="flex items-center justify-between">
                                {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((star) => (
                                    <button
                                        key={star}
                                        onClick={() => handleSetRating(star)}
                                        className="p-1 hover:scale-125 transition-transform"
                                        title={`${star}/10`}
                                    >
                                        <Star
                                            className={`w-3.5 h-3.5 ${
                                                rating && star <= rating
                                                    ? "text-yellow-500 fill-yellow-500"
                                                    : "text-muted-foreground/40 hover:text-yellow-400"
                                            }`}
                                        />
                                    </button>
                                ))}
                            </div>
                        </div>

                        {status && (
                            <div className="border-t border-border pt-2">
                                <button
                                    onClick={handleRemove}
                                    className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-destructive hover:bg-destructive/10 transition-colors"
                                >
                                    <Trash2 className="w-4 h-4" />
                                    Listeden Kaldır
                                </button>
                            </div>
                        )}
                    </div>
                </>
            )}
        </div>
    );
}
