import { ProviderBadge } from "@/components/features/provider-badge";
import { WatchlistButton } from "@/components/features/watchlist-button";
import { getMovieDetails, getMovieProviders, TMDBNotFoundError } from "@/lib/tmdb";
import { getMovieWatchlistState, WatchlistStatus } from "@/app/actions/watchlist";
import { getUserSubscribedProviders } from "@/app/actions/providers";
import { MovieDetail, Provider } from "@/types";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Star, Clock, Calendar, AlertCircle } from "lucide-react";

function ProviderSection({
    title,
    providers,
    userSubscribedIds = [],
}: {
    title: string;
    providers?: Provider[];
    userSubscribedIds?: number[];
}) {
    if (!providers || providers.length === 0) return null;
    return (
        <div className="space-y-3">
            <h3 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">{title}</h3>
            <div className="flex flex-wrap gap-3">
                {providers.map((p) => {
                    const isSubscribed = userSubscribedIds.includes(p.provider_id);
                    return (
                        <div
                            key={p.provider_id}
                            className={`flex items-center gap-2 pr-4 rounded-full border transition-colors cursor-default ${
                                isSubscribed
                                    ? "bg-emerald-500/10 border-emerald-500/30 text-emerald-300"
                                    : "bg-muted/30 border-white/5 hover:bg-muted/50 text-foreground"
                            }`}
                        >
                            <ProviderBadge provider={p} size={40} isSubscribed={isSubscribed} />
                            <div className="flex items-center gap-1.5">
                                <span className="text-sm font-medium">{p.provider_name}</span>
                                {isSubscribed && (
                                    <span className="text-[10px] bg-emerald-500/20 text-emerald-400 font-semibold px-2 py-0.5 rounded-full">
                                        Abonesiniz
                                    </span>
                                )}
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;
    try {
        const movie = await getMovieDetails(id);
        return {
            title: `${movie.title} - Nerede İzlenir?`,
            description: movie.overview.slice(0, 160),
            openGraph: {
                images: movie.backdrop_path ? [`https://image.tmdb.org/t/p/w1280${movie.backdrop_path}`] : [],
            }
        };
    } catch {
        return { title: 'Film Detayı | CineSeeker' };
    }
}

export default async function MoviePage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;

    // Parallel fetch details and providers with proper error isolation
    let movie: MovieDetail;
    try {
        movie = await getMovieDetails(id);
    } catch (error) {
        if (error instanceof TMDBNotFoundError) {
            notFound();
        }
        // P0.2 FIX: Upstream error (TMDB is down, 500, network error) must NOT turn into a 404!
        return (
            <div className="container mx-auto px-4 py-20 text-center space-y-4">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-destructive/10 text-destructive mb-2">
                    <AlertCircle className="w-6 h-6" />
                </div>
                <h1 className="text-2xl font-bold">Film Bilgileri Alınamadı</h1>
                <p className="text-muted-foreground max-w-md mx-auto">
                    Film veritabanına bağlanırken geçici bir sorun oluştu. Bu bir &quot;bulunamadı&quot; hatası değildir. Lütfen kısa süre sonra tekrar deneyin.
                </p>
                <div className="pt-4">
                    <Link href="/" className="inline-flex items-center px-4 py-2 rounded-lg bg-muted hover:bg-muted/80 text-sm font-medium transition-colors">
                        Ana Sayfaya Dön
                    </Link>
                </div>
            </div>
        );
    }

    // Fetch providers, user watchlist state, and subscriptions in parallel
    const [providersResult, watchlistState, userSubs] = await Promise.all([
        getMovieProviders(id),
        getMovieWatchlistState(Number(id)),
        getUserSubscribedProviders(),
    ]);

    const userSubscribedIds = userSubs.map((s) => s.providerId);
    const director = movie.credits?.crew.find(c => c.job === "Director");
    const cast = movie.credits?.cast.slice(0, 10) || [];

    return (
        <div className="space-y-12 pb-20">
            {/* Hero Section */}
            <div className="relative -mt-8 mx-auto">
                <div className="relative aspect-video max-h-[60vh] w-full overflow-hidden rounded-b-3xl">
                    {movie.backdrop_path ? (
                        <Image
                            src={`https://image.tmdb.org/t/p/original${movie.backdrop_path}`}
                            alt={movie.title}
                            fill
                            className="object-cover opacity-60"
                            priority
                        />
                    ) : (
                        <div className="w-full h-full bg-muted" />
                    )}
                    <div className="absolute inset-0 bg-gradient-to-t from-background via-background/60 to-transparent" />

                    <div className="absolute bottom-0 left-0 right-0 p-4 md:p-8 container mx-auto">
                        <div className="flex flex-col md:flex-row gap-8 items-end">
                            {/* Poster */}
                            <div className="relative w-32 md:w-48 aspect-[2/3] rounded-lg overflow-hidden shrink-0 border-2 border-white/10 shadow-2xl hidden md:block">
                                {movie.poster_path ? (
                                    <Image src={`https://image.tmdb.org/t/p/w500${movie.poster_path}`} alt={movie.title} fill className="object-cover" />
                                ) : (
                                    <div className="w-full h-full bg-muted flex items-center justify-center text-muted-foreground">Afiş Yok</div>
                                )}
                            </div>

                            {/* Text Info */}
                            <div className="flex-1 space-y-4 mb-4">
                                <h1 className="text-3xl md:text-5xl font-black tracking-tight">{movie.title}</h1>
                                {movie.original_title !== movie.title && (
                                    <p className="text-lg text-muted-foreground">{movie.original_title}</p>
                                )}

                                <div className="flex flex-wrap items-center gap-4 text-sm font-medium text-gray-300">
                                    <div className="flex items-center gap-1.5 text-yellow-500">
                                        <Star className="w-4 h-4 fill-current" />
                                        <span className="text-foreground">{movie.vote_average.toFixed(1)}</span>
                                        <span className="text-muted-foreground text-xs">({movie.vote_count})</span>
                                    </div>
                                    {movie.release_date && (
                                        <div className="flex items-center gap-1.5">
                                            <Calendar className="w-4 h-4" />
                                            <span>{new Date(movie.release_date).getFullYear()}</span>
                                        </div>
                                    )}
                                    {movie.runtime && (
                                        <div className="flex items-center gap-1.5">
                                            <Clock className="w-4 h-4" />
                                            <span>{Math.floor(movie.runtime / 60)}s {movie.runtime % 60}dk</span>
                                        </div>
                                    )}
                                    {movie.genres?.map(g => (
                                        <span key={g.id} className="bg-white/10 px-2 py-0.5 rounded text-xs">{g.name}</span>
                                    ))}
                                </div>

                                {/* Watchlist Action Button */}
                                <div className="pt-2">
                                    <WatchlistButton
                                        movieId={movie.id}
                                        title={movie.title}
                                        posterPath={movie.poster_path}
                                        voteAverage={movie.vote_average ? movie.vote_average.toString() : null}
                                        releaseYear={movie.release_date ? new Date(movie.release_date).getFullYear().toString() : null}
                                        initialStatus={watchlistState.item?.status as WatchlistStatus}
                                        initialRating={watchlistState.item?.rating}
                                        variant="full"
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div className="grid md:grid-cols-3 gap-12 max-w-6xl mx-auto">
                {/* Left: Where to Watch & Overview */}
                <div className="md:col-span-2 space-y-10">
                    {/* Provider Grid */}
                    <div className="bg-card rounded-2xl p-6 border border-white/5 space-y-6">
                        <h2 className="text-xl font-bold border-b border-white/5 pb-4">Nerede İzlenir?</h2>

                        {providersResult.status === "success" && (
                            <div className="space-y-8">
                                <ProviderSection
                                    title="Yayın Platformları (Abonelik)"
                                    providers={providersResult.data.flatrate}
                                    userSubscribedIds={userSubscribedIds}
                                />
                                <ProviderSection
                                    title="Kirala"
                                    providers={providersResult.data.rent}
                                    userSubscribedIds={userSubscribedIds}
                                />
                                <ProviderSection
                                    title="Satın Al"
                                    providers={providersResult.data.buy}
                                    userSubscribedIds={userSubscribedIds}
                                />
                            </div>
                        )}

                        {providersResult.status === "empty" && (
                            <div className="py-4 text-muted-foreground">
                                Bu film için Türkiye&apos;de erişilebilir bir dijital platform bulunamadı.
                            </div>
                        )}

                        {providersResult.status === "error" && (
                            <div className="py-4 px-4 bg-amber-500/10 border border-amber-500/20 rounded-xl text-amber-300 text-sm flex items-center gap-2">
                                <AlertCircle className="w-4 h-4 shrink-0 text-amber-400" />
                                <span>Yayın platformu bilgileri geçici olarak alınamadı.</span>
                            </div>
                        )}
                    </div>

                    <div>
                        <h2 className="text-xl font-bold mb-4">Özet</h2>
                        <p className="text-gray-300 leading-relaxed text-lg">{movie.overview || "Özet bulunmuyor."}</p>
                    </div>
                </div>

                {/* Right: Cast & Crew */}
                <div className="space-y-8">
                    <div>
                        <h3 className="text-lg font-bold mb-4">Künye</h3>
                        <div className="space-y-4">
                            {director && (
                                <div>
                                    <span className="text-muted-foreground block text-sm">Yönetmen</span>
                                    <Link href={`/person/${director.id}`} className="font-medium hover:text-primary">{director.name}</Link>
                                </div>
                            )}
                        </div>
                    </div>

                    <div>
                        <h3 className="text-lg font-bold mb-4">Oyuncular</h3>
                        <ul className="space-y-3">
                            {cast.map(person => (
                                <li key={person.id}>
                                    <Link href={`/person/${person.id}`} className="flex items-center gap-3 group">
                                        {person.profile_path ? (
                                            <Image
                                                src={`https://image.tmdb.org/t/p/w185${person.profile_path}`}
                                                alt={person.name}
                                                width={40}
                                                height={40}
                                                className="rounded-full object-cover w-10 h-10 bg-muted"
                                            />
                                        ) : (
                                            <div className="w-10 h-10 rounded-full bg-muted flex items-center justify-center text-xs">?</div>
                                        )}
                                        <div>
                                            <div className="font-medium group-hover:text-primary transition-colors">{person.name}</div>
                                            <div className="text-xs text-muted-foreground">{person.character}</div>
                                        </div>
                                    </Link>
                                </li>
                            ))}
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    );
}
