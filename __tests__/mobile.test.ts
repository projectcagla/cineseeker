import { describe, expect, it, vi, beforeEach } from "vitest";
import { catalogQuery } from "../lib/mobile/catalog";
import { NextRequest } from "next/server";
const { session, fetchTMDB } = vi.hoisted(() => ({ session: vi.fn(), fetchTMDB: vi.fn() }));
vi.mock("@/lib/auth", () => ({ getAuth: () => ({ api: { getSession: session } }) }));
vi.mock("@/lib/tmdb", () => ({ fetchTMDB }));
vi.mock("@/lib/db", () => ({ getDb: () => { throw new Error("Database must not be reached by unauthorized requests"); } }));
import { GET as catalog } from "../app/api/mobile/catalog/route";
import { GET, POST } from "../app/api/mobile/library/route";
describe("native mobile API", () => {
  beforeEach(() => { session.mockReset(); fetchTMDB.mockReset(); });
  it("rejects arbitrary paths, invalid identifiers and expensive pages", () => {
    for (const query of [{ action: "../../account" }, { action: "detail" }, { action: "discover", page: 501 }, { action: "discover", providers: "8&api_key=bad" }]) {
      expect(catalogQuery.safeParse(query).success).toBe(false);
    }
  });
  it("requires a real session without trusting cached cookies", async () => {
    session.mockResolvedValue(null);
    expect((await GET(new NextRequest("https://cine.example/api/mobile/library"))).status).toBe(401);
    expect(session).toHaveBeenCalledWith(expect.objectContaining({ query: { disableCookieCache: true } }));
  });
  it("blocks cross-origin mutations before touching the database", async () => {
    const request = new NextRequest("https://cine.example/api/mobile/library", { method: "POST", headers: { origin: "https://evil.example" }, body: "{}" });
    expect((await POST(request)).status).toBe(403);
    expect(session).not.toHaveBeenCalled();
  });
  it("rejects an offline mutation queued by another account", async () => {
    session.mockResolvedValue({ user: { id: "account-b" } });
    const request = new NextRequest("https://cine.example/api/mobile/library", { method: "POST", headers: { origin: "https://cine.example", "x-cineseeker-user": "account-a" }, body: "{}" });
    expect((await POST(request)).status).toBe(409);
  });
  it("normalizes television details and selects only Turkish offers", async () => {
    fetchTMDB.mockImplementation((path: string) => path.endsWith("watch/providers") ? { results: { TR: { flatrate: [{ provider_id: 8 }] }, US: { buy: [] } } } : { id: 42, name: "Dizi", genres: [] });
    const response = await catalog(new NextRequest("https://cine.example/api/mobile/catalog?action=detail&media=tv&id=42"));
    expect(await response.json()).toMatchObject({ id: 42, media_type: "tv", providers_tr: { flatrate: [{ provider_id: 8 }] } });
    expect(fetchTMDB).toHaveBeenCalledWith("/tv/42", expect.any(Object));
  });
  it("returns a distinct upstream error rather than an empty catalog", async () => {
    fetchTMDB.mockRejectedValue(new Error("secret upstream detail"));
    const response = await catalog(new NextRequest("https://cine.example/api/mobile/catalog?action=genres"));
    expect(response.status).toBe(502);
    expect(JSON.stringify(await response.json())).not.toContain("secret");
  });
});
