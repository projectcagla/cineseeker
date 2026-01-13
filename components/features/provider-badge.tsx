import Image from "next/image";
import { Provider } from "@/types";

interface ProviderBadgeProps {
    provider: Provider;
    size?: number;
    className?: string;
}

export function ProviderBadge({ provider, size = 32, className }: ProviderBadgeProps) {
    return (
        <div
            className={`relative rounded-full overflow-hidden border border-white/10 shrink-0 ${className}`}
            style={{ width: size, height: size }}
            title={provider.provider_name}
        >
            <Image
                src={`https://image.tmdb.org/t/p/original${provider.logo_path}`}
                alt={provider.provider_name}
                fill
                className="object-cover"
                sizes={`${size}px`}
            />
        </div>
    );
}
