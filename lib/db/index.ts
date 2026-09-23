import { drizzle } from "drizzle-orm/d1";
import * as schema from "./schema";
import { getCloudflareContext } from "@opennextjs/cloudflare";

export type AppDatabase = ReturnType<typeof drizzle<typeof schema>>;

export function getDb(d1Instance?: D1Database): AppDatabase {
    let dbBinding = d1Instance;
    if (!dbBinding) {
        try {
            const { env } = getCloudflareContext();
            const cfEnv = env as unknown as { DB?: D1Database };
            if (cfEnv && cfEnv.DB) {
                dbBinding = cfEnv.DB;
            }
        } catch {
            // Fallback for build time or non-Workers execution
        }
    }

    if (!dbBinding) {
        throw new Error("Cloudflare D1 Database binding 'DB' is missing.");
    }

    return drizzle(dbBinding, { schema });
}
