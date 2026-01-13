import { MovieCard } from "@/components/features/movie-card";
import { bg_augmentWithProviders, getSearchMovies } from "@/lib/tmdb";

export default async function SearchPage({
    searchParams,
}: {
    searchParams: Promise<{ q: string }>;
}) {
    const { q } = await searchParams;

    if (!q) {
        return <div className="text-center py-20">Aramak için bir şeyler yazın...</div>;
    }

    const data = await getSearchMovies(q);
    // Sort logic could go here: boost exact matches

    // Augment with providers
    const movies = await bg_augmentWithProviders(data.results.slice(0, 12));

    return (
        <div className="space-y-6">
            <h1 className="text-xl font-medium text-muted-foreground">
                &quot;<span className="text-foreground font-bold">{q}</span>&quot; için sonuçlar
            </h1>

            {movies.length > 0 ? (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-x-4 gap-y-8">
                    {movies.map((movie) => (
                        <MovieCard key={movie.id} movie={movie} />
                    ))}
                </div>
            ) : (
                <div className="py-20 text-center text-muted-foreground">
                    Sonuç bulunamadı. Farklı bir arama yapmayı deneyin.
                </div>
            )}
        </div>
    );
}
