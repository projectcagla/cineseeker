import { getServerSession } from "@/lib/session";
import { getDb } from "@/lib/db";
import { user } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function POST() {
    const session = await getServerSession();
    if (!session) {
        return NextResponse.json({ error: "Yetkisiz işlem. Giriş yapmalısınız." }, { status: 401 });
    }

    const userId = session.user.id;
    const db = getDb();

    // In SQLite with foreign keys ON DELETE CASCADE, deleting user deletes all associated data
    await db.delete(user).where(eq(user.id, userId));

    return NextResponse.json({
        success: true,
        message: "Hesabınız ve tüm verileriniz kalıcı olarak silindi.",
    });
}
