"use client";

import { useState } from "react";
import { Movie, WatchProviders } from "@/types";
import { MovieCard } from "./movie-card";
import { RecentArrival } from "@/lib/cron/get-new-arrivals";
import Link from "next/link";
import Image from "next/image";
import { Tv, Flame, Sparkles, PlusCircle } from "lucide-react";

interface HomeMovieFeedProps {
    initialMovies: (Movie & { providers_tr?: WatchProviders | null })[];
    userSubscribedIds: number[];
    recentArrivals?: RecentArrival[];
}

export function HomeMovieFeed({
    initialMovies,
    userSubscribedIds = [],
    recentArrivals = [],
}: HomeMovieFeedProps) {
    const [activeTab, setActiveTab] = useState<"all" | "subscribed" | "recent">("all");

    // Filter for movies matching user's subscriptions
    const subscribedMovies = initialMovies.filter((m) => {
        const flatrate = m.providers_tr?.flatrate || [];
        return flatrate.some((p) => userSubscribedIds.includes(p.provider_id));
    });

    return (
        <div className="space-y-6">
            {/* Filter Tabs Header */}
            <div className="flex flex-wrap items-center justify-between gap-3 border-b border-border/50 pb-4">
                <div className="flex items-center gap-2 p-1 bg-muted/40 rounded-xl border border-border text-sm overflow-x-auto">
                    <button
                        onClick={() => setActiveTab("all")}
                        className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap ${
                            activeTab === "all"
                                ? "bg-card text-foreground shadow-sm"
                                : "text-muted-foreground hover:text-foreground"
                        }`}
                    >
                        <Flame className="w-4 h-4 text-orange-400" />
                        Yeni & Popüler
                    </button>

                    <button
                        onClick={() => setActiveTab("subscribed")}
                        className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap ${
                            activeTab === "subscribed"
                                ? "bg-card text-foreground shadow-sm"
                                : "text-muted-foreground hover:text-foreground"
                        }`}
                    >
                        <Tv className="w-4 h-4 text-primary" />
                        Sadece Platformlarım
                        {userSubscribedIds.length > 0 && (
                            <span className="ml-1 px-1.5 py-0.2 rounded-full bg-primary/20 text-primary text-[11px] font-bold">
                                {userSubscribedIds.length}
                            </span>
                        )}
                    </button>

                    {recentArrivals.length > 0 && (
                        <button
                            onClick={() => setActiveTab("recent")}
                            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition-colors whitespace-nowrap ${
                                activeTab === "recent"
                                    ? "bg-card text-foreground shadow-sm"
                                    : "text-muted-foreground hover:text-foreground"
                            }`}
                        >
                            <Sparkles className="w-4 h-4 text-yellow-400" />
                            Yeni Gelenler ({recentArrivals.length})
                        </button>
                    )}
                </div>

                {userSubscribedIds.length > 0 && (
                    <Link
                        href="/profil/platformlar"
                        className="text-xs text-muted-foreground hover:text-primary transition-colors flex items-center gap-1"
                    >
                        <span>Platformları Yönet</span>
                    </Link>
                )}
            </div>

            {/* Tab: Subscribed Platforms */}
            {activeTab === "subscribed" && (
                <div>
                    {userSubscribedIds.length === 0 ? (
                        <div className="text-center py-16 px-4 bg-card/40 border border-dashed border-border rounded-2xl space-y-4">
                            <div className="w-12 h-12 rounded-full bg-primary/10 text-primary flex items-center justify-center mx-auto">
                                <Tv className="w-6 h-6" />
                            </div>
                            <div className="space-y-1">
                                <h3 className="font-bold text-base">Henüz Platform Seçmediniz</h3>
                                <p className="text-sm text-muted-foreground max-w-md mx-auto">
                                    Netflix, Prime, Disney+ veya Blutv gibi kullandığınız servisleri işaretleyerek sadece abone olduğunuz platformlardaki filmleri listeleyebilirsiniz.
                                </p>
                            </div>
                            <Link
                                href="/profil/platformlar"
                                className="inline-flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground font-semibold rounded-xl text-sm hover:bg-primary/90 transition-colors"
                            >
                                <PlusCircle className="w-4 h-4" />
                                Platformlarımı Seç
                            </Link>
                        </div>
                    ) : subscribedMovies.length === 0 ? (
                        <div className="text-center py-16 px-4 text-muted-foreground bg-card/40 border border-border rounded-2xl space-y-2">
                            <p className="font-medium">Seçtiğiniz platformlarda bu listede henüz eşleşen film bulunamadı.</p>
                            <p className="text-xs">Farklı platformları listenize ekleyebilir veya tüm filmleri inceleyebilirsiniz.</p>
                        </div>
                    ) : (
                        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-x-4 gap-y-8">
                            {subscribedMovies.map((movie) => (
                                <MovieCard
                                    key={movie.id}
                                    movie={movie}
                                    userSubscribedIds={userSubscribedIds}
                                />
                            ))}
                        </div>
                    )}
                </div>
            )}

            {/* Tab: All Movies */}
            {activeTab === "all" && (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-x-4 gap-y-8">
                    {initialMovies.map((movie) => (
                        <MovieCard
                            key={movie.id}
                            movie={movie}
                            userSubscribedIds={userSubscribedIds}
                        />
                    ))}
                </div>
            )}

            {/* Tab: Recent Arrivals from Nightly Ingestion */}
            {activeTab === "recent" && recentArrivals.length > 0 && (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-x-4 gap-y-8">
                    {recentArrivals.map((arrival) => (
                        <Link
                            key={`${arrival.tmdbId}-${arrival.providerId}`}
                            href={`/movie/${arrival.tmdbId}`}
                            className="group block relative"
                        >
                            <div className="relative aspect-[2/3] rounded-lg overflow-hidden bg-muted transition-transform group-hover:scale-[1.02] duration-300">
                                {arrival.posterPath ? (
                                    <Image
                                        src={`https://image.tmdb.org/t/p/w500${arrival.posterPath}`}
                                        alt={arrival.title}
                                        fill
                                        className="object-cover"
                                        sizes="(max-width: 768px) 50vw, 20vw"
                                    />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center text-muted-foreground text-xs">
                                        Afiş Yok
                                    </div>
                                )}
                                <div className="absolute top-2 left-2 bg-emerald-500/90 text-white text-[10px] font-bold px-2 py-0.5 rounded-full shadow">
                                    Yeni Eklendi
                                </div>
                            </div>
                            <div className="mt-2.5 space-y-1">
                                <h3 className="text-sm font-semibold truncate group-hover:text-primary transition-colors">
                                    {arrival.title}
                                </h3>
                                <p className="text-xs text-muted-foreground">
                                    {new Date(arrival.firstSeenAt).toLocaleDateString("tr-TR")}
                                </p>
                            </div>
                        </Link>
                    ))}
                </div>
            )}
        </div>
    );
}
