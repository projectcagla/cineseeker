import { describe, it, expect } from "vitest";
import { loginSchema, registerSchema, forgotPasswordSchema, resetPasswordSchema } from "@/lib/validations/auth";
import { watchlistItemSchema, updateWatchlistSchema, toggleProviderSchema } from "@/lib/validations/watchlist";

describe("Auth Validation Schemas", () => {
    describe("loginSchema", () => {
        it("should accept valid email and password", () => {
            const valid = { email: "test@example.com", password: "password123" };
            const res = loginSchema.safeParse(valid);
            expect(res.success).toBe(true);
        });

        it("should reject invalid email format", () => {
            const invalid = { email: "not-an-email", password: "password123" };
            const res = loginSchema.safeParse(invalid);
            expect(res.success).toBe(false);
        });

        it("should reject empty password", () => {
            const invalid = { email: "test@example.com", password: "" };
            const res = loginSchema.safeParse(invalid);
            expect(res.success).toBe(false);
        });
    });

    describe("registerSchema", () => {
        it("should accept valid registration data", () => {
            const valid = {
                name: "Ahmet Yılmaz",
                email: "ahmet@example.com",
                password: "strongPassword123",
            };
            const res = registerSchema.safeParse(valid);
            expect(res.success).toBe(true);
        });

        it("should reject names shorter than 2 characters", () => {
            const invalid = {
                name: "A",
                email: "ahmet@example.com",
                password: "password123",
            };
            const res = registerSchema.safeParse(invalid);
            expect(res.success).toBe(false);
        });

        it("should reject passwords shorter than 8 characters", () => {
            const invalid = {
                name: "Ahmet Yılmaz",
                email: "ahmet@example.com",
                password: "short",
            };
            const res = registerSchema.safeParse(invalid);
            expect(res.success).toBe(false);
        });
    });

    describe("forgotPasswordSchema", () => {
        it("should validate email for password reset", () => {
            expect(forgotPasswordSchema.safeParse({ email: "user@domain.com" }).success).toBe(true);
            expect(forgotPasswordSchema.safeParse({ email: "invalid" }).success).toBe(false);
        });
    });

    describe("resetPasswordSchema", () => {
        it("should require password with >= 8 chars", () => {
            expect(
                resetPasswordSchema.safeParse({
                    password: "newStrongPassword1",
                }).success
            ).toBe(true);

            expect(
                resetPasswordSchema.safeParse({
                    password: "pass1",
                }).success
            ).toBe(false);
        });
    });
});

describe("Watchlist Validation Schemas", () => {
    describe("watchlistItemSchema", () => {
        it("should accept valid watchlist item", () => {
            const valid = {
                tmdbId: 157336,
                mediaType: "movie",
                title: "Interstellar",
                posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
                voteAverage: "8.4",
                releaseYear: "2014",
                status: "want",
                rating: 9,
            };
            const res = watchlistItemSchema.safeParse(valid);
            expect(res.success).toBe(true);
        });

        it("should reject negative or non-integer tmdbId", () => {
            const invalid = {
                tmdbId: -5,
                mediaType: "movie",
                title: "Bad Movie",
                status: "want",
            };
            const res = watchlistItemSchema.safeParse(invalid);
            expect(res.success).toBe(false);
        });

        it("should reject rating outside 1-10 range", () => {
            const invalid = {
                tmdbId: 123,
                mediaType: "movie",
                title: "Test",
                status: "watched",
                rating: 15,
            };
            const res = watchlistItemSchema.safeParse(invalid);
            expect(res.success).toBe(false);
        });
    });

    describe("updateWatchlistSchema", () => {
        it("should validate status update", () => {
            const valid = { id: "item-uuid-1", status: "watched", rating: 8 };
            const res = updateWatchlistSchema.safeParse(valid);
            expect(res.success).toBe(true);
        });
    });

    describe("toggleProviderSchema", () => {
        it("should accept valid provider details", () => {
            const valid = {
                providerId: 8,
                providerName: "Netflix",
                logoPath: "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg",
            };
            const res = toggleProviderSchema.safeParse(valid);
            expect(res.success).toBe(true);
        });

        it("should reject invalid provider ID", () => {
            const invalid = {
                providerId: -1,
                providerName: "Fake",
                logoPath: "/fake.jpg",
            };
            expect(toggleProviderSchema.safeParse(invalid).success).toBe(false);
        });
    });
});
