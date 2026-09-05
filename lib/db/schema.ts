import { sqliteTable, text, integer, primaryKey, index, uniqueIndex } from "drizzle-orm/sqlite-core";

// ========================================================
// Better Auth Core Tables (user, session, account, verification)
// ========================================================

export const user = sqliteTable("user", {
    id: text("id").primaryKey(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    emailVerified: integer("email_verified", { mode: "boolean" }).notNull().default(false),
    image: text("image"),
    createdAt: integer("created_at", { mode: "timestamp" }).notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp" }).notNull(),
});

export const session = sqliteTable("session", {
    id: text("id").primaryKey(),
    userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
    token: text("token").notNull().unique(),
    expiresAt: integer("expires_at", { mode: "timestamp" }).notNull(),
    ipAddress: text("ip_address"),
    userAgent: text("user_agent"),
    createdAt: integer("created_at", { mode: "timestamp" }).notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp" }).notNull(),
}, (table) => [
    index("session_user_idx").on(table.userId),
    index("session_token_idx").on(table.token),
]);

export const account = sqliteTable("account", {
    id: text("id").primaryKey(),
    userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
    accountId: text("account_id").notNull(),
    providerId: text("provider_id").notNull(),
    accessToken: text("access_token"),
    refreshToken: text("refresh_token"),
    accessTokenExpiresAt: integer("access_token_expires_at", { mode: "timestamp" }),
    refreshTokenExpiresAt: integer("refresh_token_expires_at", { mode: "timestamp" }),
    scope: text("scope"),
    password: text("password"),
    createdAt: integer("created_at", { mode: "timestamp" }).notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp" }).notNull(),
}, (table) => [
    index("account_user_idx").on(table.userId),
]);

export const verification = sqliteTable("verification", {
    id: text("id").primaryKey(),
    identifier: text("identifier").notNull(),
    value: text("value").notNull(),
    expiresAt: integer("expires_at", { mode: "timestamp" }).notNull(),
    createdAt: integer("created_at", { mode: "timestamp" }),
    updatedAt: integer("updated_at", { mode: "timestamp" }),
}, (table) => [
    index("verification_identifier_idx").on(table.identifier),
]);

// ========================================================
// Application Tables
// ========================================================

// 1. User Profile (Region preference, expandable for multi-country)
export const userProfile = sqliteTable("user_profile", {
    userId: text("user_id").primaryKey().references(() => user.id, { onDelete: "cascade" }),
    region: text("region").notNull().default("TR"),
    createdAt: integer("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
    updatedAt: integer("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
});

// 2. User Subscribed Providers (Platforms the user pays for)
export const userProvider = sqliteTable("user_provider", {
    userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
    providerId: integer("provider_id").notNull(), // TMDB provider_id (e.g. 8: Netflix, 119: Prime)
    providerName: text("provider_name").notNull(),
    logoPath: text("logo_path").notNull(),
    createdAt: integer("created_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
}, (table) => [
    primaryKey({ columns: [table.userId, table.providerId] }),
    index("user_provider_user_idx").on(table.userId),
]);

// 3. Watchlist Items (User's saved movies and watch status)
export const watchlistItem = sqliteTable("watchlist_item", {
    id: text("id").primaryKey(),
    userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
    tmdbId: integer("tmdb_id").notNull(),
    mediaType: text("media_type").notNull().default("movie"), // 'movie' | 'tv'
    title: text("title").notNull(),
    posterPath: text("poster_path"),
    voteAverage: text("vote_average"),
    releaseYear: text("release_year"),
    status: text("status").notNull().default("want"), // 'want' | 'watching' | 'watched'
    rating: integer("rating"), // 1-10 (nullable)
    addedAt: integer("added_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
    updatedAt: integer("updated_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
}, (table) => [
    uniqueIndex("watchlist_user_tmdb_media_idx").on(table.userId, table.tmdbId, table.mediaType),
    index("watchlist_user_status_idx").on(table.userId, table.status),
    index("watchlist_added_at_idx").on(table.addedAt),
]);

// 4. Availability Snapshot (Tracks newly added provider availability over time)
export const availabilitySnapshot = sqliteTable("availability_snapshot", {
    tmdbId: integer("tmdb_id").notNull(),
    mediaType: text("media_type").notNull().default("movie"),
    region: text("region").notNull().default("TR"),
    providerId: integer("provider_id").notNull(),
    monetization: text("monetization").notNull(), // 'flatrate' | 'rent' | 'buy'
    title: text("title").notNull(),
    posterPath: text("poster_path"),
    firstSeenAt: integer("first_seen_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
    lastSeenAt: integer("last_seen_at", { mode: "timestamp" }).notNull().$defaultFn(() => new Date()),
}, (table) => [
    primaryKey({ columns: [table.tmdbId, table.mediaType, table.region, table.providerId, table.monetization] }),
    index("snapshot_region_provider_idx").on(table.region, table.providerId),
    index("snapshot_first_seen_idx").on(table.firstSeenAt),
    index("snapshot_last_seen_idx").on(table.lastSeenAt),
]);
