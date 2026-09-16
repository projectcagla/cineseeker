import { NextRequest, NextResponse } from "next/server";
import { getAuth } from "@/lib/auth";
import { getDb } from "@/lib/db";
import { userProvider, watchlistItem } from "@/lib/db/schema";
import { and, eq } from "drizzle-orm";
import { z } from "zod";
import { watchlistItemSchema, toggleProviderSchema } from "@/lib/validations/watchlist";
export const dynamic = "force-dynamic";
const mutation = z.discriminatedUnion("kind", [
  z.object({ kind: z.literal("save"), item: watchlistItemSchema }),
  z.object({ kind: z.literal("remove"), tmdbId: z.number().int().positive(), mediaType: z.enum(["movie", "tv"]) }),
  z.object({ kind: z.literal("provider"), provider: toggleProviderSchema, selected: z.boolean() }),
]);
async function identity(req: NextRequest) {
  return getAuth().api.getSession({ headers: req.headers, query: { disableCookieCache: true } });
}
export async function GET(req: NextRequest) {
  const session = await identity(req);
  if (!session) return NextResponse.json({ error: "Oturum açmanız gerekiyor." }, { status: 401 });
  if (req.headers.has("x-cineseeker-user") && req.headers.get("x-cineseeker-user") !== session.user.id) return NextResponse.json({ error: "Hesap değişti. Yeniden giriş yapın." }, { status: 409 });
  const db = getDb();
  const [watchlist, providers] = await Promise.all([
    db.select().from(watchlistItem).where(eq(watchlistItem.userId, session.user.id)),
    db.select().from(userProvider).where(eq(userProvider.userId, session.user.id)),
  ]);
  return NextResponse.json({ watchlist, providers }, { headers: { "Cache-Control": "no-store" } });
}
export async function POST(req: NextRequest) {
  // Require same-origin for cookie-authenticated mutations, including the native client.
  if (req.headers.get("origin") !== req.nextUrl.origin) return NextResponse.json({ error: "Geçersiz kaynak." }, { status: 403 });
  const session = await identity(req);
  if (!session) return NextResponse.json({ error: "Oturum açmanız gerekiyor." }, { status: 401 });
  if (req.headers.has("x-cineseeker-user") && req.headers.get("x-cineseeker-user") !== session.user.id) return NextResponse.json({ error: "Hesap değişti. Yeniden giriş yapın." }, { status: 409 });
  const parsed = mutation.safeParse(await req.json().catch(() => null));
  if (!parsed.success) return NextResponse.json({ error: "Geçersiz veri." }, { status: 400 });
  const input = parsed.data, db = getDb(), userId = session.user.id;
  if (input.kind === "provider") {
    const p = input.provider;
    if (input.selected) await db.insert(userProvider).values({ userId, ...p }).onConflictDoNothing();
    else await db.delete(userProvider).where(and(eq(userProvider.userId, userId), eq(userProvider.providerId, p.providerId)));
  } else if (input.kind === "remove") {
    await db.delete(watchlistItem).where(and(eq(watchlistItem.userId, userId), eq(watchlistItem.tmdbId, input.tmdbId), eq(watchlistItem.mediaType, input.mediaType)));
  } else {
    const item = input.item;
    await db.insert(watchlistItem).values({ id: crypto.randomUUID(), userId, ...item }).onConflictDoUpdate({
      target: [watchlistItem.userId, watchlistItem.tmdbId, watchlistItem.mediaType],
      set: { ...item, rating: item.rating ?? null, updatedAt: new Date() },
    });
  }
  return NextResponse.json({ success: true });
}
