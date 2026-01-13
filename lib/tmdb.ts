import { Credits, Movie, MovieDetail, Person, TMDBResponse, WatchProviders } from "@/types";
import pLimit from "p-limit";

const TMDB_API_KEY = process.env.TMDB_API_KEY;
const BASE_URL = "https://api.themoviedb.org/3";

if (!TMDB_API_KEY) {
    console.warn("TMDB_API_KEY is missing in environment variables.");
}

const limit = pLimit(10); // Concurrency limit for parallel requests

async function fetchTMDB<T>(path: string, params: Record<string, string> = {}): Promise<T> {
    const query = new URLSearchParams({
        api_key: TMDB_API_KEY || "",
        language: "tr-TR",
        ...params,
    });

    const url = `${BASE_URL}${path}?${query.toString()}`;

    try {
        const res = await fetch(url, {
            next: { revalidate: 3600 }, // Cache for 1 hour default
            headers: {
                "Content-Type": "application/json",
            },
        });

        if (!res.ok) {
            throw new Error(`TMDB API Error: ${res.status} ${res.statusText}`);
        }

        return await res.json();
    } catch (error) {
        console.error(`Error fetching ${url}:`, error);
        throw error;
    }
}

export async function getTrendingMovies() {
    // Fetch movies popular in TR
    // Using discover to ensure we prioritize region availability if possible, 
    // or just standard trending.
    // Strategy: Discover popular, filtered by available in TR.
    return fetchTMDB<TMDBResponse<Movie>>("/discover/movie", {
        region: "TR",
        sort_by: "popularity.desc",
        watch_region: "TR",
        with_watch_monetization_types: "flatrate|rent|buy",
        "vote_count.gte": "100" // Filter out noise
    });
}

export async function getNewInTr() {
    // "New" means recently released and available in TR
    const today = new Date().toISOString().split("T")[0];
    const threeMonthsAgo = new Date();
    threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
    const dateStr = threeMonthsAgo.toISOString().split("T")[0];

    return fetchTMDB<TMDBResponse<Movie>>("/discover/movie", {
        region: "TR",
        sort_by: "primary_release_date.desc",
        watch_region: "TR",
        with_watch_monetization_types: "flatrate", // Focus on subscription services for "new"
        "primary_release_date.gte": dateStr,
        "primary_release_date.lte": today,
        "vote_count.gte": "50"
    });
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

export async function getMovieProviders(id: number | string): Promise<WatchProviders | null> {
    const data = await fetchTMDB<{ results: Record<string, WatchProviders> }>(`/movie/${id}/watch/providers`);
    return data.results["TR"] || null;
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
                try {
                    const providers = await getMovieProviders(movie.id);
                    return { ...movie, providers_tr: providers };
                } catch (e) {
                    return { ...movie, providers_tr: null };
                }
            })
        )
    );
    return enriched;
}
