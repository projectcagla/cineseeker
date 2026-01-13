import Link from "next/link";
import Image from "next/image";
import { Movie, WatchProviders } from "@/types";
import { Star } from "lucide-react";
import { ProviderBadge } from "./provider-badge";

interface MovieCardProps {
    movie: Movie & { providers_tr?: WatchProviders | null };
}

export function MovieCard({ movie }: MovieCardProps) {
    const providers = movie.providers_tr?.flatrate?.slice(0, 3) || [];
    const hasMore = (movie.providers_tr?.flatrate?.length || 0) > 3;

    return (
        <Link href={`/movie/${movie.id}`} className="group block relative">
            <div className="relative aspect-[2/3] rounded-lg overflow-hidden bg-muted transition-transform group-hover:scale-[1.02] duration-300">
                {movie.poster_path ? (
                    <Image
                        src={`https://image.tmdb.org/t/p/w500${movie.poster_path}`}
                        alt={movie.title}
                        fill
                        className="object-cover"
                        sizes="(max-width: 768px) 50vw, 20vw"
                    />
                ) : (
                    <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                        No Poster
                    </div>
                )}

                {/* Overlay Gradient on hover */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />

                {/* Rating Badge */}
                <div className="absolute top-2 right-2 bg-black/60 backdrop-blur-md px-1.5 py-0.5 rounded flex items-center gap-1 text-xs font-medium border border-white/10">
                    <Star className="w-3 h-3 text-yellow-500 fill-yellow-500" />
                    <span>{movie.vote_average.toFixed(1)}</span>
                </div>
            </div>

            <div className="mt-3 space-y-1">
                <h3 className="text-sm font-semibold truncate leading-tight group-hover:text-primary transition-colors">
                    {movie.title}
                </h3>
                <p className="text-xs text-muted-foreground truncate">
                    {movie.original_title !== movie.title ? movie.original_title : new Date(movie.release_date).getFullYear()}
                </p>

                {/* Provider Icons */}
                {providers.length > 0 && (
                    <div className="flex -space-x-2 pt-1.5 overflow-hidden">
                        {providers.map((p) => (
                            <ProviderBadge
                                key={p.provider_id}
                                provider={p}
                                size={24}
                                className="ring-2 ring-background grayscale group-hover:grayscale-0 transition-all"
                            />
                        ))}
                        {hasMore && (
                            <div className="w-6 h-6 rounded-full bg-muted flex items-center justify-center text-[10px] ring-2 ring-background shrink-0">
                                +
                            </div>
                        )}
                    </div>
                )}
            </div>
        </Link>
    );
}
