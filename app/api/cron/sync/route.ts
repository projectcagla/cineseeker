import { NextRequest, NextResponse } from "next/server";
import { syncProviderAvailability } from "@/lib/cron/sync-providers";
import { getCloudflareContext } from "@opennextjs/cloudflare";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
    return handleSync(request);
}

export async function POST(request: NextRequest) {
    return handleSync(request);
}

async function handleSync(request: NextRequest) {
    // Check authorization header or query param
    const authHeader = request.headers.get("authorization");
    const token = authHeader?.replace("Bearer ", "") || request.nextUrl.searchParams.get("secret");

    let expectedSecret: string | undefined;
    try {
        const { env } = getCloudflareContext();
        expectedSecret = (env as unknown as { CRON_SECRET?: string }).CRON_SECRET;
    } catch {
        expectedSecret = process.env.CRON_SECRET;
    }

    // In production with CRON_SECRET configured, require exact match
    if (expectedSecret && token !== expectedSecret) {
        return NextResponse.json({ error: "Yetkisiz erişim: CRON_SECRET geçersiz." }, { status: 401 });
    }

    try {
        const result = await syncProviderAvailability();
        return NextResponse.json({
            success: true,
            timestamp: new Date().toISOString(),
            ...result,
        });
    } catch (err) {
        return NextResponse.json(
            {
                success: false,
                error: err instanceof Error ? err.message : "Sync failed",
            },
            { status: 500 }
        );
    }
}
