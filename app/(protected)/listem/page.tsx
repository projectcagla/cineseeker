import { getServerSession } from "@/lib/session";
import { redirect } from "next/navigation";
import { getUserWatchlist } from "@/app/actions/watchlist";
import { WatchlistClient } from "./watchlist-client";
import { Metadata } from "next";

export const dynamic = "force-dynamic";

export const metadata: Metadata = {
    title: "İzleme Listem | CineSeeker",
    description: "Kaydettiğiniz ve izlediğiniz filmler.",
};

export default async function WatchlistPage() {
    const session = await getServerSession();
    if (!session) {
        redirect("/giris?next=/listem");
    }

    const items = await getUserWatchlist();

    return (
        <div className="py-6">
            <WatchlistClient initialItems={items} />
        </div>
    );
}
