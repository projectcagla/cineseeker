import { HomeMovieFeed } from "@/components/features/home-movie-feed";
import { bg_augmentWithProviders, getNewInTr } from "@/lib/tmdb";
import { getUserSubscribedProviders } from "@/app/actions/providers";
import { getRecentProviderArrivals } from "@/lib/cron/get-new-arrivals";
import { Suspense } from "react";

export const dynamic = "force-dynamic";

async function MovieGrid() {
  const [data, userSubs, recentArrivals] = await Promise.all([
    getNewInTr(),
    getUserSubscribedProviders().catch(() => []),
    getRecentProviderArrivals(18).catch(() => []),
  ]);

  const movies = await bg_augmentWithProviders(data.results.slice(0, 18));
  const userSubscribedIds = userSubs.map((s) => s.providerId);

  if (movies.length === 0 && recentArrivals.length === 0) {
    return <div className="text-center py-20 text-muted-foreground">Şu an gösterilecek içerik bulunamadı.</div>;
  }

  return (
    <HomeMovieFeed
      initialMovies={movies}
      userSubscribedIds={userSubscribedIds}
      recentArrivals={recentArrivals}
    />
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
