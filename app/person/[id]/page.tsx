import { MovieCard } from "@/components/features/movie-card";
import { bg_augmentWithProviders, getPerson } from "@/lib/tmdb";
import { Movie } from "@/types";
import Image from "next/image";
import { notFound } from "next/navigation";

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;
    const person = await getPerson(id).catch(() => null);
    if (!person) return { title: 'Kişi Bulunamadı' };
    return {
        title: `${person.name} - Filmografisi`,
        description: person.biography.slice(0, 160)
    };
}

export default async function PersonPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;
    const person = await getPerson(id).catch(() => null);

    if (!person) notFound();

    // Determine filmography to show
    // If has director credits, show them. Otherwise show cast credits.
    // Filter for movies only.

    const directorCredits = person.combined_credits?.crew
        .filter(c => c.media_type === 'movie' && c.job === 'Director')
        .map(c => ({ ...c, job: 'Director' })) || [];

    const actorCredits = person.combined_credits?.cast
        .filter(c => c.media_type === 'movie') || [];

    const isDirector = directorCredits.length > 0;

    // Sort by release date desc
    const moviesRaw = (isDirector ? directorCredits : actorCredits) as unknown as Movie[];
    const sortedMovies = moviesRaw
        .filter(m => m.poster_path && m.vote_count > 10) // Filter junk
        .sort((a, b) => b.popularity - a.popularity) // Show most popular first
        .slice(0, 18); // Limit to top 18

    // Augment with providers
    const movies = await bg_augmentWithProviders(sortedMovies);

    return (
        <div className="space-y-12">
            <div className="flex flex-col md:flex-row gap-8 items-start">
                <div className="relative w-48 aspect-[2/3] rounded-xl overflow-hidden shrink-0 border border-white/10 bg-muted">
                    {person.profile_path ? (
                        <Image src={`https://image.tmdb.org/t/p/w500${person.profile_path}`} alt={person.name} fill className="object-cover" />
                    ) : (
                        <div className="w-full h-full flex items-center justify-center text-muted-foreground text-4xl font-bold">
                            {person.name.charAt(0)}
                        </div>
                    )}
                </div>

                <div className="space-y-4 max-w-2xl">
                    <h1 className="text-4xl font-black tracking-tight">{person.name}</h1>
                    <div className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
                        {isDirector ? "Yönetmen" : "Oyuncu"}
                    </div>
                    <p className="text-muted-foreground leading-relaxed line-clamp-6 hover:line-clamp-none transition-all cursor-pointer">
                        {person.biography || "Biyografi bulunmuyor."}
                    </p>
                    {person.place_of_birth && (
                        <div className="text-sm text-muted-foreground">
                            <span className="font-medium text-foreground">Doğum Yeri:</span> {person.place_of_birth}
                        </div>
                    )}
                </div>
            </div>

            <div className="space-y-6">
                <h2 className="text-2xl font-bold">
                    En Popüler Filmleri
                </h2>
                {movies.length > 0 ? (
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-x-4 gap-y-8">
                        {movies.map((movie) => (
                            <MovieCard key={movie.id} movie={movie} />
                        ))}
                    </div>
                ) : (
                    <div className="text-muted-foreground">Film kaydı bulunamadı.</div>
                )}
            </div>
        </div>
    );
}
