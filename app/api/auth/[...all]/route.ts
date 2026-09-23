import { getAuth } from "@/lib/auth";
import { NextRequest } from "next/server";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
    const auth = getAuth();
    return auth.handler(request);
}

export async function POST(request: NextRequest) {
    const auth = getAuth();
    return auth.handler(request);
}
