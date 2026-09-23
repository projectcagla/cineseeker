"use server";

import { getServerSession } from "@/lib/session";
import { getDb } from "@/lib/db";
import { userProvider } from "@/lib/db/schema";
import { toggleProviderSchema } from "@/lib/validations/watchlist";
import { and, eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";

export interface ProviderActionResponse<T = unknown> {
    success: boolean;
    data?: T;
    error?: string;
}

export async function getUserSubscribedProviders() {
    const session = await getServerSession();
    if (!session) {
        return [];
    }

    const db = getDb();
    const userId = session.user.id;

    try {
        const providers = await db
            .select()
            .from(userProvider)
            .where(eq(userProvider.userId, userId));

        return providers;
    } catch (err) {
        console.error("getUserSubscribedProviders error:", err);
        return [];
    }
}

export async function toggleUserSubscribedProvider(
    rawInput: unknown
): Promise<ProviderActionResponse<{ subscribed: boolean; providerId: number }>> {
    const session = await getServerSession();
    if (!session) {
        return { success: false, error: "Lütfen önce giriş yapın." };
    }

    const parseResult = toggleProviderSchema.safeParse(rawInput);
    if (!parseResult.success) {
        return { success: false, error: parseResult.error.issues[0]?.message || "Geçersiz veri." };
    }

    const { providerId, providerName, logoPath } = parseResult.data;
    const db = getDb();
    const userId = session.user.id;

    try {
        const [existing] = await db
            .select()
            .from(userProvider)
            .where(
                and(
                    eq(userProvider.userId, userId),
                    eq(userProvider.providerId, providerId)
                )
            )
            .limit(1);

        if (existing) {
            await db
                .delete(userProvider)
                .where(
                    and(
                        eq(userProvider.userId, userId),
                        eq(userProvider.providerId, providerId)
                    )
                );

            revalidatePath("/profil/platformlar");
            revalidatePath("/");
            return { success: true, data: { subscribed: false, providerId } };
        }

        await db.insert(userProvider).values({
            userId,
            providerId,
            providerName,
            logoPath,
            createdAt: new Date(),
        });

        revalidatePath("/profil/platformlar");
        revalidatePath("/");
        return { success: true, data: { subscribed: true, providerId } };
    } catch (err) {
        console.error("toggleUserSubscribedProvider error:", err);
        return { success: false, error: "Platform durumu güncellenirken bir hata oluştu." };
    }
}
