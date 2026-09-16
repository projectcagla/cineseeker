import { NextRequest, NextResponse } from "next/server";
import { fetchTMDB } from "@/lib/tmdb";
import { catalogQuery } from "@/lib/mobile/catalog";
import { getDb } from "@/lib/db";
import { availabilitySnapshot } from "@/lib/db/schema";
import { and, desc, eq, gte } from "drizzle-orm";
import pLimit from "p-limit";
export const dynamic = "force-dynamic";
type Title = { id: number; [key: string]: unknown };
type Offers = { results: Record<string, unknown> };
export async function GET(request: NextRequest) {
  const parsed = catalogQuery.safeParse(Object.fromEntries(request.nextUrl.searchParams));
  if (!parsed.success) return NextResponse.json({ error: "Geçersiz istek." }, { status: 400 });
  const q = parsed.data;
  try {
    let result: unknown;
    if (q.action === "providers") {
      const [movies, tv] = await Promise.all(["movie", "tv"].map(m => fetchTMDB<{ results: { provider_id: number }[] }>(`/watch/providers/${m}`, { watch_region: "TR" })));
      result = { results: [...new Map([...movies.results, ...tv.results].map(p => [p.provider_id, p])).values()] };
    } else if (q.action === "genres") {
      result = await fetchTMDB(`/genre/${q.media}/list`);
    } else if (q.action === "detail") {
      const [detail, offers] = await Promise.all([
        fetchTMDB<Title>(`/${q.media}/${q.id}`, { append_to_response: "credits" }),
        fetchTMDB<Offers>(`/${q.media}/${q.id}/watch/providers`),
      ]);
      result = { ...detail, media_type: q.media, providers_tr: offers.results.TR ?? null };
    } else {
      let titles: Title[];
      let totalPages = 1;
      if (q.action === "arrivals") {
        // Observed additions, not theatrical release dates. The initial scan is a baseline.
        const rows = await getDb().select().from(availabilitySnapshot).where(and(
          eq(availabilitySnapshot.region, "TR"), eq(availabilitySnapshot.mediaType, q.media),
          gte(availabilitySnapshot.firstSeenAt, new Date(Date.now() - 30 * 86400000)),
          gte(availabilitySnapshot.lastSeenAt, new Date(Date.now() - 2 * 86400000)),
        )).orderBy(desc(availabilitySnapshot.firstSeenAt)).limit(200);
        const ids = [...new Set(rows.map(r => r.tmdbId))].slice(0, 40);
        const limit = pLimit(5);
        titles = await Promise.all(ids.map(id => limit(() => fetchTMDB<Title>(`/${q.media}/${id}`))));
      } else {
        const params: Record<string, string> = { page: String(q.page), include_adult: "false", region: "TR" };
        if (q.action === "search") params.query = q.query;
        else Object.assign(params, { watch_region: "TR", with_watch_monetization_types: "flatrate|rent|buy", sort_by: "popularity.desc" });
        if (q.providers) { params.with_watch_providers = q.providers; params.with_watch_monetization_types = "flatrate"; }
        if (q.genre) params.with_genres = String(q.genre);
        const data = await fetchTMDB<{ results: Title[]; total_pages: number }>(`/${q.action}/${q.media}`, params);
        titles = data.results;
        totalPages = data.total_pages;
        if (q.action === "search" && q.genre) titles = titles.filter(t => Array.isArray(t.genre_ids) && t.genre_ids.includes(q.genre));
      }
      const limit = pLimit(5);
      const enriched = await Promise.all(titles.map(title => limit(async () => {
        try {
          const offers = await fetchTMDB<Offers>(`/${q.media}/${title.id}/watch/providers`);
          return { ...title, media_type: q.media, providers_tr: offers.results.TR ?? null };
        } catch { return { ...title, media_type: q.media, providers_tr: null, providers_error: true }; }
      })));
      result = { results: enriched, page: q.page, total_pages: totalPages };
    }
    return NextResponse.json(result, { headers: { "Cache-Control": "public, max-age=60, s-maxage=300" } });
  } catch {
    return NextResponse.json({ error: "İçerikler şu anda alınamıyor. Lütfen tekrar deneyin." }, { status: 502 });
  }
}
