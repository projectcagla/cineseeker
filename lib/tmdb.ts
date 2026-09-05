import { Movie, MovieDetail, Person, TMDBResponse, WatchProviders, WatchProvidersResult } from "@/types";
import { getCloudflareContext } from "@opennextjs/cloudflare";
import pLimit from "p-limit";

const BASE_URL = "https://api.themoviedb.org/3";

export function getTMDBApiKey(): string {
    try {
        const { env } = getCloudflareContext();
        const cfEnv = env as unknown as { TMDB_API_KEY?: string };
        if (cfEnv && typeof cfEnv.TMDB_API_KEY === "string") {
            return cfEnv.TMDB_API_KEY.trim();
        }
    } catch {
        // Fallback for build time, SSG, or local node environment
    }
    return (process.env.TMDB_API_KEY || "").trim();
}

export class TMDBNotFoundError extends Error {
    constructor(path: string) {
        super(`TMDB Not Found: ${path}`);
        this.name = "TMDBNotFoundError";
    }
}

export class TMDBUpstreamError extends Error {
    statusCode: number;
    constructor(path: string, status: number, statusText: string) {
        super(`TMDB Upstream Error [${status}]: ${statusText} for ${path}`);
        this.name = "TMDBUpstreamError";
        this.statusCode = status;
    }
}

const limit = pLimit(10); // Concurrency limit for parallel requests

async function fetchTMDB<T>(path: string, params: Record<string, string> = {}): Promise<T> {
    const apiKey = getTMDBApiKey();

    const headers: Record<string, string> = {
        "Content-Type": "application/json",
    };

    const queryParams: Record<string, string> = {
        language: "tr-TR",
        ...params,
    };

    // If apiKey is a v4 Read Access Token (starts with eyJ), use Bearer header.
    // If it's a v3 32-char key, pass as api_key query param.
    if (apiKey.startsWith("eyJ")) {
        headers["Authorization"] = `Bearer ${apiKey}`;
    } else if (apiKey && apiKey !== "your_v3_api_key_here") {
        queryParams["api_key"] = apiKey;
    }

    const query = new URLSearchParams(queryParams);
    const queryString = query.toString();
    const url = `${BASE_URL}${path}${queryString ? `?${queryString}` : ""}`;

    try {
        const res = await fetch(url, {
            next: { revalidate: 3600 }, // Cache for 1 hour default
            headers,
        });

        if (res.status === 404) {
            throw new TMDBNotFoundError(path);
        }

        if (!res.ok) {
            throw new TMDBUpstreamError(path, res.status, res.statusText);
        }

        return await res.json();
    } catch (error) {
        // SECURITY P0 FIX: Never log the URL or query string containing api_key.
        // Only log path and safe error message.
        console.error(`[TMDB] Error fetching path: ${path} -`, error instanceof Error ? error.message : "Unknown error");
        throw error;
    }
}

export async function getTrendingMovies(): Promise<TMDBResponse<Movie>> {
    try {
        return await fetchTMDB<TMDBResponse<Movie>>("/discover/movie", {
            region: "TR",
            sort_by: "popularity.desc",
            watch_region: "TR",
            with_watch_monetization_types: "flatrate|rent|buy",
            "vote_count.gte": "100"
        });
    } catch (error) {
        if (error instanceof TMDBNotFoundError) {
            return { page: 1, results: [], total_pages: 0, total_results: 0 };
        }
        // If placeholder key or offline during build, return empty response gracefully
        const key = getTMDBApiKey();
        if (!key || key === "your_v3_api_key_here") {
            return { page: 1, results: [], total_pages: 0, total_results: 0 };
        }
        throw error;
    }
}

export async function getNewInTr(): Promise<TMDBResponse<Movie>> {
    try {
        const today = new Date().toISOString().split("T")[0];
        const threeMonthsAgo = new Date();
        threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
        const dateStr = threeMonthsAgo.toISOString().split("T")[0];

        return await fetchTMDB<TMDBResponse<Movie>>("/discover/movie", {
            region: "TR",
            sort_by: "primary_release_date.desc",
            watch_region: "TR",
            with_watch_monetization_types: "flatrate",
            "primary_release_date.gte": dateStr,
            "primary_release_date.lte": today,
            "vote_count.gte": "50"
        });
    } catch (error) {
        if (error instanceof TMDBNotFoundError) {
            return { page: 1, results: [], total_pages: 0, total_results: 0 };
        }
        const key = getTMDBApiKey();
        if (!key || key === "your_v3_api_key_here") {
            return { page: 1, results: [], total_pages: 0, total_results: 0 };
        }
        throw error;
    }
}

export async function getSearchMovies(query: string) {
    return fetchTMDB<TMDBResponse<Movie>>("/search/movie", {
        query,
        include_adult: "false",
        region: "TR"
    });
}

export async function getMovieDetails(id: string) {
    return fetchTMDB<MovieDetail>(`/movie/${id}`, {
        append_to_response: "credits,recommendations,external_ids"
    });
}

export async function getMovieProviders(id: number | string): Promise<WatchProvidersResult> {
    try {
        const data = await fetchTMDB<{ results: Record<string, WatchProviders> }>(`/movie/${id}/watch/providers`);
        const trProviders = data?.results?.["TR"];
        if (!trProviders || (
            (!trProviders.flatrate || trProviders.flatrate.length === 0) &&
            (!trProviders.rent || trProviders.rent.length === 0) &&
            (!trProviders.buy || trProviders.buy.length === 0)
        )) {
            return { status: "empty" };
        }
        return { status: "success", data: trProviders };
    } catch (error) {
        if (error instanceof TMDBNotFoundError) {
            return { status: "empty" };
        }
        return {
            status: "error",
            error: error instanceof Error ? error.message : "Sağlayıcı bilgisi alınamadı."
        };
    }
}

export async function getPerson(id: string) {
    return fetchTMDB<Person>(`/person/${id}`, {
        append_to_response: "combined_credits"
    });
}

// Batch fetch providers for a list of movies
export async function bg_augmentWithProviders(movies: Movie[]) {
    const enriched = await Promise.all(
        movies.map((movie) =>
            limit(async () => {
                const providersResult = await getMovieProviders(movie.id);
                return {
                    ...movie,
                    providers_tr: providersResult.status === "success" ? providersResult.data : null
                };
            })
        )
    );
    return enriched;
}
