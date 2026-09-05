import { getDb } from "@/lib/db";
import { availabilitySnapshot } from "@/lib/db/schema";
import { desc, eq } from "drizzle-orm";

export interface RecentArrival {
    tmdbId: number;
    title: string;
    posterPath: string | null;
    providerId: number;
    monetization: string;
    firstSeenAt: Date;
}

export async function getRecentProviderArrivals(limitCount: number = 18): Promise<RecentArrival[]> {
    try {
        const db = getDb();
        const rows = await db
            .select()
            .from(availabilitySnapshot)
            .where(eq(availabilitySnapshot.region, "TR"))
            .orderBy(desc(availabilitySnapshot.firstSeenAt))
            .limit(limitCount * 2); // Over-fetch to deduplicate by movie ID

        const seenMovieIds = new Set<number>();
        const uniqueArrivals: RecentArrival[] = [];

        for (const row of rows) {
            if (!seenMovieIds.has(row.tmdbId)) {
                seenMovieIds.add(row.tmdbId);
                uniqueArrivals.push({
                    tmdbId: row.tmdbId,
                    title: row.title,
                    posterPath: row.posterPath,
                    providerId: row.providerId,
                    monetization: row.monetization,
                    firstSeenAt: row.firstSeenAt,
                });
            }
            if (uniqueArrivals.length >= limitCount) break;
        }

        return uniqueArrivals;
    } catch {
        // Fallback for build time or empty database
        return [];
    }
}
