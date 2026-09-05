"use server";

import { getServerSession } from "@/lib/session";
import { getDb } from "@/lib/db";
import { watchlistItem } from "@/lib/db/schema";
import { watchlistItemSchema } from "@/lib/validations/watchlist";
import { and, eq, desc } from "drizzle-orm";
import { revalidatePath } from "next/cache";

export type WatchlistStatus = "want" | "watching" | "watched";

export interface WatchlistActionResponse<T = unknown> {
    success: boolean;
    data?: T;
    error?: string;
}

export async function addToWatchlist(
    rawInput: unknown
): Promise<WatchlistActionResponse<{ id: string; status: WatchlistStatus }>> {
    const session = await getServerSession();
    if (!session) {
        return { success: false, error: "İşlem yapabilmek için lütfen giriş yapın." };
    }

    const parseResult = watchlistItemSchema.safeParse(rawInput);
    if (!parseResult.success) {
        return { success: false, error: parseResult.error.issues[0]?.message || "Geçersiz veri." };
    }

    const { tmdbId, mediaType, title, posterPath, voteAverage, releaseYear, status, rating } = parseResult.data;
    const db = getDb();
    const userId = session.user.id;

    try {
        // Check if item already exists
        const [existing] = await db
            .select()
            .from(watchlistItem)
            .where(
                and(
                    eq(watchlistItem.userId, userId),
                    eq(watchlistItem.tmdbId, tmdbId),
                    eq(watchlistItem.mediaType, mediaType)
                )
            )
            .limit(1);

        const now = new Date();

        if (existing) {
            await db
                .update(watchlistItem)
                .set({
                    status,
                    rating: rating !== undefined ? rating : existing.rating,
                    updatedAt: now,
                })
                .where(eq(watchlistItem.id, existing.id));

            revalidatePath("/listem");
            return { success: true, data: { id: existing.id, status } };
        }

        const id = crypto.randomUUID();
        await db.insert(watchlistItem).values({
            id,
            userId,
            tmdbId,
            mediaType,
            title,
            posterPath: posterPath || null,
            voteAverage: voteAverage || null,
            releaseYear: releaseYear || null,
            status,
            rating: rating || null,
            addedAt: now,
            updatedAt: now,
        });

        revalidatePath("/listem");
        return { success: true, data: { id, status } };
    } catch (err) {
        console.error("addToWatchlist error:", err);
        return { success: false, error: "Listeye eklenirken bir veritabanı hatası oluştu." };
    }
}

export async function removeFromWatchlist(
    tmdbId: number,
    mediaType: "movie" | "tv" = "movie"
): Promise<WatchlistActionResponse> {
    const session = await getServerSession();
    if (!session) {
        return { success: false, error: "İşlem yapabilmek için lütfen giriş yapın." };
    }

    const db = getDb();
    const userId = session.user.id;

    try {
        await db
            .delete(watchlistItem)
            .where(
                and(
                    eq(watchlistItem.userId, userId),
                    eq(watchlistItem.tmdbId, tmdbId),
                    eq(watchlistItem.mediaType, mediaType)
                )
            );

        revalidatePath("/listem");
        return { success: true };
    } catch (err) {
        console.error("removeFromWatchlist error:", err);
        return { success: false, error: "Listeden çıkarılırken bir hata oluştu." };
    }
}

export async function updateWatchlistStatus(
    tmdbId: number,
    status: WatchlistStatus,
    rating?: number | null,
    mediaType: "movie" | "tv" = "movie"
): Promise<WatchlistActionResponse> {
    const session = await getServerSession();
    if (!session) {
        return { success: false, error: "İşlem yapabilmek için lütfen giriş yapın." };
    }

    const db = getDb();
    const userId = session.user.id;

    try {
        const updateData: { status: WatchlistStatus; updatedAt: Date; rating?: number | null } = {
            status,
            updatedAt: new Date(),
        };

        if (rating !== undefined) {
            updateData.rating = rating;
        }

        await db
            .update(watchlistItem)
            .set(updateData)
            .where(
                and(
                    eq(watchlistItem.userId, userId),
                    eq(watchlistItem.tmdbId, tmdbId),
                    eq(watchlistItem.mediaType, mediaType)
                )
            );

        revalidatePath("/listem");
        return { success: true };
    } catch (err) {
        console.error("updateWatchlistStatus error:", err);
        return { success: false, error: "Durum güncellenirken bir hata oluştu." };
    }
}

export async function getMovieWatchlistState(
    tmdbId: number,
    mediaType: "movie" | "tv" = "movie"
) {
    const session = await getServerSession();
    if (!session) {
        return { inWatchlist: false, item: null };
    }

    const db = getDb();
    const userId = session.user.id;

    try {
        const [item] = await db
            .select()
            .from(watchlistItem)
            .where(
                and(
                    eq(watchlistItem.userId, userId),
                    eq(watchlistItem.tmdbId, tmdbId),
                    eq(watchlistItem.mediaType, mediaType)
                )
            )
            .limit(1);

        return {
            inWatchlist: !!item,
            item: item || null,
        };
    } catch {
        return { inWatchlist: false, item: null };
    }
}

export async function getUserWatchlist(statusFilter?: WatchlistStatus) {
    const session = await getServerSession();
    if (!session) {
        return [];
    }

    const db = getDb();
    const userId = session.user.id;

    try {
        const conditions = [eq(watchlistItem.userId, userId)];
        if (statusFilter) {
            conditions.push(eq(watchlistItem.status, statusFilter));
        }

        const items = await db
            .select()
            .from(watchlistItem)
            .where(and(...conditions))
            .orderBy(desc(watchlistItem.addedAt));

        return items;
    } catch (err) {
        console.error("getUserWatchlist error:", err);
        return [];
    }
}
