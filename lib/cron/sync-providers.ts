import { getDb, AppDatabase } from "@/lib/db";
import { availabilitySnapshot } from "@/lib/db/schema";
import { getTMDBApiKey, fetchTMDB } from "@/lib/tmdb";
import { and, eq } from "drizzle-orm";
import { Movie, WatchProviders } from "@/types";

export interface SyncResult {
    scannedMovies: number;
    newSnapshots: number;
    updatedSnapshots: number;
    errors: string[];
}

export async function syncProviderAvailability(customDb?: AppDatabase): Promise<SyncResult> {
    const db = customDb || getDb();
    const apiKey = getTMDBApiKey();

    if (!apiKey || apiKey === "your_v3_api_key_here") {
        return {
            scannedMovies: 0,
            newSnapshots: 0,
            updatedSnapshots: 0,
            errors: ["TMDB_API_KEY is not configured or is a placeholder."],
        };
    }

    const result: SyncResult = {
        scannedMovies: 0,
        newSnapshots: 0,
        updatedSnapshots: 0,
        errors: [],
    };

    try {
        // Fetch up to 25 popular / trending titles in Turkey
        const discoverData = await fetchTMDB<{ results: Movie[] }>("/discover/movie", {
            region: "TR",
            sort_by: "popularity.desc",
            watch_region: "TR",
            with_watch_monetization_types: "flatrate|rent|buy",
            page: "1",
        });

        const movies = (discoverData?.results || []).slice(0, 25);
        result.scannedMovies = movies.length;

        const now = new Date();

        for (const movie of movies) {
            try {
                const providerData = await fetchTMDB<{ results: Record<string, WatchProviders> }>(
                    `/movie/${movie.id}/watch/providers`
                );

                const trProviders = providerData?.results?.["TR"];
                if (!trProviders) continue;

                // Process flatrate (subscription), rent, buy
                const monetizationTypes: Array<{ type: "flatrate" | "rent" | "buy"; list?: typeof trProviders.flatrate }> = [
                    { type: "flatrate", list: trProviders.flatrate },
                    { type: "rent", list: trProviders.rent },
                    { type: "buy", list: trProviders.buy },
                ];

                for (const { type, list } of monetizationTypes) {
                    if (!list || list.length === 0) continue;

                    for (const prov of list) {
                        const [existing] = await db
                            .select()
                            .from(availabilitySnapshot)
                            .where(
                                and(
                                    eq(availabilitySnapshot.tmdbId, movie.id),
                                    eq(availabilitySnapshot.mediaType, "movie"),
                                    eq(availabilitySnapshot.region, "TR"),
                                    eq(availabilitySnapshot.providerId, prov.provider_id),
                                    eq(availabilitySnapshot.monetization, type)
                                )
                            )
                            .limit(1);

                        if (existing) {
                            await db
                                .update(availabilitySnapshot)
                                .set({ lastSeenAt: now })
                                .where(
                                    and(
                                        eq(availabilitySnapshot.tmdbId, movie.id),
                                        eq(availabilitySnapshot.mediaType, "movie"),
                                        eq(availabilitySnapshot.region, "TR"),
                                        eq(availabilitySnapshot.providerId, prov.provider_id),
                                        eq(availabilitySnapshot.monetization, type)
                                    )
                                );
                            result.updatedSnapshots++;
                        } else {
                            await db.insert(availabilitySnapshot).values({
                                tmdbId: movie.id,
                                mediaType: "movie",
                                region: "TR",
                                providerId: prov.provider_id,
                                monetization: type,
                                title: movie.title,
                                posterPath: movie.poster_path || null,
                                firstSeenAt: now,
                                lastSeenAt: now,
                            });
                            result.newSnapshots++;
                        }
                    }
                }
            } catch (err) {
                const msg = `Movie ${movie.id} sync failed: ${err instanceof Error ? err.message : String(err)}`;
                result.errors.push(msg);
            }
        }
    } catch (err) {
        result.errors.push(`Discovery fetch failed: ${err instanceof Error ? err.message : String(err)}`);
    }

    return result;
}
