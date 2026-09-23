export interface TMDBResponse<T> {
    page: number;
    results: T[];
    total_pages: number;
    total_results: number;
}

export interface Movie {
    id: number;
    title: string;
    original_title: string;
    poster_path: string | null;
    backdrop_path: string | null;
    overview: string;
    release_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids?: number[];
    popularity: number;
}

export interface Genre {
    id: number;
    name: string;
}

export interface MovieDetail extends Movie {
    genres: Genre[];
    runtime: number | null;
    status: string;
    tagline: string | null;
    credits?: Credits;
    recommendations?: TMDBResponse<Movie>;
    external_ids?: {
        imdb_id: string | null;
        instagram_id: string | null;
        twitter_id: string | null;
    };
}

export interface Cast {
    id: number;
    name: string;
    original_name: string;
    character: string;
    profile_path: string | null;
    order: number;
}

export interface Crew {
    id: number;
    name: string;
    original_name: string;
    job: string;
    department: string;
    profile_path: string | null;
}

export interface Credits {
    cast: Cast[];
    crew: Crew[];
}

export interface Provider {
    provider_id: number;
    provider_name: string;
    logo_path: string;
    display_priority: number;
}

export interface WatchProviders {
    link: string;
    flatrate?: Provider[];
    rent?: Provider[];
    buy?: Provider[];
}

export type WatchProvidersResult =
    | { status: "success"; data: WatchProviders }
    | { status: "empty" }
    | { status: "error"; error: string };

export interface Person {
    id: number;
    name: string;
    biography: string;
    birthday: string | null;
    deathday: string | null;
    place_of_birth: string | null;
    profile_path: string | null;
    combined_credits?: {
        cast: (Movie & { media_type: 'movie' | 'tv' })[];
        crew: (Movie & { media_type: 'movie' | 'tv'; job: string })[];
    };
}
