import { getServerSession } from "@/lib/session";
import { redirect } from "next/navigation";
import { getUserSubscribedProviders } from "@/app/actions/providers";
import { getAvailableProviders } from "@/lib/tmdb";
import { PlatformsClient, PlatformItem } from "./platforms-client";
import { Metadata } from "next";

export const dynamic = "force-dynamic";

export const metadata: Metadata = {
    title: "Platform Aboneliklerim | CineSeeker",
    description: "Kullandığınız yayın platformlarını seçin.",
};

// Curated top Turkish streaming platforms with reliable logos
const DEFAULT_TURKISH_PLATFORMS: PlatformItem[] = [
    { providerId: 8, providerName: "Netflix", logoPath: "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg" },
    { providerId: 119, providerName: "Amazon Prime Video", logoPath: "/dQeAar5H991VYporEjUspolDarG.jpg" },
    { providerId: 337, providerName: "Disney Plus", logoPath: "/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg" },
    { providerId: 342, providerName: "BluTV", logoPath: "/ovmuV24BqVf66E87A5B9WJ3yK6H.jpg" },
    { providerId: 600, providerName: "TOD", logoPath: "/4aM8L5YnJ20aRz6dM0W9i8e7K4J.jpg" },
    { providerId: 1845, providerName: "Gain", logoPath: "/9g8L88r5e1b1M6jVw6p4k4f0a9b.jpg" },
    { providerId: 11, providerName: "MUBI", logoPath: "/bVR4ZpQn2i8Wn23k9o8j5p2g1h.jpg" },
    { providerId: 350, providerName: "Apple TV Plus", logoPath: "/6whA9jXv9K6K9u9e1t2p4f0a9b.jpg" },
    { providerId: 534, providerName: "TV+", logoPath: "/k7l4W9n8m6p1k4f0a9b2c3d4e5f.jpg" },
    { providerId: 3, providerName: "Google Play Movies", logoPath: "/tbEdFQDwx5LEVr8WpSeXQSIirVq.jpg" },
];

export default async function PlatformsPage() {
    const session = await getServerSession();
    if (!session) {
        redirect("/giris?next=/profil/platformlar");
    }

    const [userSubs, tmdbProviders] = await Promise.all([
        getUserSubscribedProviders(),
        getAvailableProviders("TR").catch(() => []),
    ]);

    const initialSubscribedIds = userSubs.map((s) => s.providerId);

    // Merge curated with TMDB providers if available
    const platformMap = new Map<number, PlatformItem>();

    DEFAULT_TURKISH_PLATFORMS.forEach((p) => platformMap.set(p.providerId, p));

    tmdbProviders.forEach((p) => {
        if (p.logo_path && !platformMap.has(p.provider_id)) {
            platformMap.set(p.provider_id, {
                providerId: p.provider_id,
                providerName: p.provider_name,
                logoPath: p.logo_path,
            });
        }
    });

    const allPlatforms = Array.from(platformMap.values());

    return (
        <div className="py-6">
            <PlatformsClient
                allPlatforms={allPlatforms}
                initialSubscribedIds={initialSubscribedIds}
            />
        </div>
    );
}
