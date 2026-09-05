import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { getDb } from "./db";
import * as schema from "./db/schema";
import { sendPasswordResetEmail, sendVerificationEmail } from "./email";
import { getCloudflareContext } from "@opennextjs/cloudflare";

function getAuthSecret(): string {
    try {
        const { env } = getCloudflareContext();
        const cfEnv = env as unknown as { BETTER_AUTH_SECRET?: string };
        if (cfEnv?.BETTER_AUTH_SECRET) return cfEnv.BETTER_AUTH_SECRET;
    } catch {
        // Fallback
    }
    return process.env.BETTER_AUTH_SECRET || "development-secret-must-be-at-least-32-characters-long";
}

function getAppUrl(): string {
    try {
        const { env } = getCloudflareContext();
        const cfEnv = env as unknown as { NEXT_PUBLIC_APP_URL?: string };
        if (cfEnv?.NEXT_PUBLIC_APP_URL) return cfEnv.NEXT_PUBLIC_APP_URL;
    } catch {
        // Fallback
    }
    return process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
}

export function createAuth(d1Instance?: D1Database) {
    const db = getDb(d1Instance);

    return betterAuth({
        database: drizzleAdapter(db, {
            provider: "sqlite",
            schema: {
                user: schema.user,
                session: schema.session,
                account: schema.account,
                verification: schema.verification,
            },
        }),
        secret: getAuthSecret(),
        baseURL: getAppUrl(),
        emailAndPassword: {
            enabled: true,
            requireEmailVerification: true,
            sendResetPassword: async ({ user, url }) => {
                await sendPasswordResetEmail({ to: user.email, url });
            },
        },
        emailVerification: {
            sendVerificationEmail: async ({ user, url }) => {
                await sendVerificationEmail({ to: user.email, url });
            },
            autoSignInAfterVerification: true,
        },
        session: {
            cookieCache: {
                enabled: true,
                maxAge: 5 * 60, // 5 minutes
            },
            expiresIn: 30 * 24 * 60 * 60, // 30 days
            updateAge: 24 * 60 * 60, // 1 day
        },
        advanced: {
            cookiePrefix: "cineseeker",
            useSecureCookies: process.env.NODE_ENV === "production",
        },
    });
}

// Request-scoped factory
export function getAuth(d1Instance?: D1Database) {
    return createAuth(d1Instance);
}
