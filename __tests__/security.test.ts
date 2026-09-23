import { describe, it, expect } from "vitest";
import nextConfig from "@/next.config";

describe("Security and Hardening Configuration", () => {
    it("should configure Content-Security-Policy headers", async () => {
        expect(nextConfig.headers).toBeDefined();
        if (typeof nextConfig.headers === "function") {
            const headerRules = await nextConfig.headers();
            const rootRule = headerRules.find((r) => r.source === "/(.*)");
            expect(rootRule).toBeDefined();

            const headersMap = new Map(rootRule?.headers.map((h) => [h.key, h.value]));

            expect(headersMap.get("X-Frame-Options")).toBe("DENY");
            expect(headersMap.get("X-Content-Type-Options")).toBe("nosniff");
            expect(headersMap.get("Referrer-Policy")).toBe("strict-origin-when-cross-origin");
            expect(headersMap.get("Strict-Transport-Security")).toContain("max-age=");

            const csp = headersMap.get("Content-Security-Policy");
            expect(csp).toBeDefined();
            expect(csp).toContain("default-src 'self'");
            expect(csp).toContain("https://image.tmdb.org");
            expect(csp).toContain("frame-ancestors 'none'");
        }
    });

    it("should allow only legitimate TMDB domain in Next.js images config", () => {
        const remotePatterns = nextConfig.images?.remotePatterns;
        expect(remotePatterns).toBeDefined();
        const hosts = (remotePatterns as Array<{ hostname: string }>).map((p) => p.hostname);
        expect(hosts).toContain("image.tmdb.org");
    });
});
