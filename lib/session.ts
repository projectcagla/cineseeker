import { headers } from "next/headers";
import { getAuth } from "./auth";

export async function getServerSession() {
    try {
        const auth = getAuth();
        const reqHeaders = await headers();
        const session = await auth.api.getSession({
            headers: reqHeaders,
        });
        return session;
    } catch {
        return null;
    }
}
