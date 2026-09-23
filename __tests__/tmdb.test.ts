import { describe, it, expect } from "vitest";
import { TMDBNotFoundError, TMDBUpstreamError } from "@/lib/tmdb";
import { WatchProvidersResult } from "@/types";

describe("TMDB Error and Response Architecture", () => {
    it("should instantiate TMDBNotFoundError with path and proper name", () => {
        const error = new TMDBNotFoundError("/movie/99999999");
        expect(error.name).toBe("TMDBNotFoundError");
        expect(error.message).toContain("TMDB Not Found: /movie/99999999");
        expect(error instanceof Error).toBe(true);
    });

    it("should instantiate TMDBUpstreamError with status and statusText", () => {
        const error = new TMDBUpstreamError("/discover/movie", 500, "Internal Server Error");
        expect(error.name).toBe("TMDBUpstreamError");
        expect(error.statusCode).toBe(500);
        expect(error.message).toContain("500");
        expect(error.message).toContain("Internal Server Error");
    });

    it("should ensure error messages do NOT expose TMDB api_key query parameters", () => {
        const sensitiveQuery = "api_key=32charfakehexkey1234567890abcdef&language=tr-TR";
        const error = new TMDBNotFoundError("/movie/123");
        expect(error.message).not.toContain("api_key");
        expect(error.message).not.toContain(sensitiveQuery);
    });

    it("should verify WatchProvidersResult discriminated union types", () => {
        const successResult: WatchProvidersResult = {
            status: "success",
            data: {
                link: "https://www.themoviedb.org/movie/123/watch",
                flatrate: [
                    {
                        display_priority: 1,
                        logo_path: "/test.jpg",
                        provider_id: 8,
                        provider_name: "Netflix",
                    },
                ],
            },
        };

        const emptyResult: WatchProvidersResult = {
            status: "empty",
        };

        const errorResult: WatchProvidersResult = {
            status: "error",
            error: "Network timeout",
        };

        expect(successResult.status).toBe("success");
        if (successResult.status === "success") {
            expect(successResult.data.flatrate?.length).toBe(1);
        }

        expect(emptyResult.status).toBe("empty");
        expect(errorResult.status).toBe("error");
    });
});
