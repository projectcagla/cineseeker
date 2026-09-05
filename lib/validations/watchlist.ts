import { z } from "zod";

export const watchlistItemSchema = z.object({
    tmdbId: z.number().int().positive("Geçersiz TMDB film ID'si"),
    mediaType: z.enum(["movie", "tv"]).default("movie"),
    title: z.string().trim().min(1, "Film başlığı zorunludur"),
    posterPath: z.string().nullable().optional(),
    voteAverage: z.string().nullable().optional(),
    releaseYear: z.string().nullable().optional(),
    status: z.enum(["want", "watching", "watched"]).default("want"),
    rating: z.number().int().min(1).max(10).nullable().optional(),
});

export const updateWatchlistSchema = z.object({
    id: z.string().min(1),
    status: z.enum(["want", "watching", "watched"]),
    rating: z.number().int().min(1).max(10).nullable().optional(),
});

export const toggleProviderSchema = z.object({
    providerId: z.number().int().positive("Geçersiz sağlayıcı ID"),
    providerName: z.string().min(1, "Sağlayıcı ismi zorunludur"),
    logoPath: z.string().min(1, "Logo yolu zorunludur"),
});
