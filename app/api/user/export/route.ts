import { getServerSession } from "@/lib/session";
import { getDb } from "@/lib/db";
import { user, userProfile, userProvider, watchlistItem } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function GET() {
    const session = await getServerSession();
    if (!session) {
        return NextResponse.json({ error: "Yetkisiz işlem. Giriş yapmalısınız." }, { status: 401 });
    }

    const userId = session.user.id;
    const db = getDb();

    const [userInfo] = await db.select().from(user).where(eq(user.id, userId)).limit(1);
    const [profile] = await db.select().from(userProfile).where(eq(userProfile.userId, userId)).limit(1);
    const providers = await db.select().from(userProvider).where(eq(userProvider.userId, userId));
    const watchlist = await db.select().from(watchlistItem).where(eq(watchlistItem.userId, userId));

    const exportData = {
        title: "CineSeeker Kişisel Veri Dışa Aktarımı (KVKK / GDPR)",
        exportedAt: new Date().toISOString(),
        user: {
            id: userInfo?.id,
            name: userInfo?.name,
            email: userInfo?.email,
            emailVerified: userInfo?.emailVerified,
            createdAt: userInfo?.createdAt,
        },
        profile: profile || null,
        subscribedProviders: providers.map(p => ({
            providerId: p.providerId,
            providerName: p.providerName,
            createdAt: p.createdAt,
        })),
        watchlist: watchlist.map(w => ({
            tmdbId: w.tmdbId,
            mediaType: w.mediaType,
            title: w.title,
            status: w.status,
            rating: w.rating,
            addedAt: w.addedAt,
            updatedAt: w.updatedAt,
        })),
    };

    return new NextResponse(JSON.stringify(exportData, null, 2), {
        headers: {
            "Content-Type": "application/json",
            "Content-Disposition": `attachment; filename="cineseeker-data-export-${userId}.json"`,
        },
    });
}
