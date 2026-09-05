import { getServerSession } from "@/lib/session";
import { redirect } from "next/navigation";
import { AccountClient } from "./account-client";

export const dynamic = "force-dynamic";

export default async function AccountPage() {
    const session = await getServerSession();
    if (!session) {
        redirect("/giris?next=/hesap");
    }

    return <AccountClient user={session.user} />;
}
