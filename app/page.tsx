import { MovieCard } from "@/components/features/movie-card";
import { bg_augmentWithProviders, getNewInTr } from "@/lib/tmdb";
import { Suspense } from "react";

async function MovieGrid() {
  const data = await getNewInTr();
  const movies = await bg_augmentWithProviders(data.results.slice(0, 18)); // Limit to 18 for grid symmetry

  if (movies.length === 0) {
    return <div className="text-center py-20 text-muted-foreground">Şu an gösterilecek içerik bulunamadı.</div>;
  }

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-x-4 gap-y-8">
      {movies.map((movie) => (
        <MovieCard key={movie.id} movie={movie} />
      ))}
    </div>
  );
}

export default function Home() {
  return (
    <div className="space-y-8">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tighter">Türkiye&apos;de Yeni ve Popüler</h1>
        <p className="text-muted-foreground text-sm max-w-2xl">
          Dijital platformlara yakın zamanda eklenen ve şu an izleyebileceğiniz en iyi filmler.
        </p>
      </div>

      <Suspense fallback={<div className="h-96 w-full flex items-center justify-center text-muted-foreground animate-pulse">Filmler yükleniyor...</div>}>
        <MovieGrid />
      </Suspense>
    </div>
  );
}
