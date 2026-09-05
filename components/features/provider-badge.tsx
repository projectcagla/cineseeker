import Image from "next/image";
import { Provider } from "@/types";

interface ProviderBadgeProps {
    provider: Provider;
    size?: number;
    className?: string;
    isSubscribed?: boolean;
}

export function ProviderBadge({ provider, size = 32, className, isSubscribed }: ProviderBadgeProps) {
    return (
        <div
            className={`relative rounded-full overflow-hidden border shrink-0 ${
                isSubscribed ? "ring-2 ring-emerald-500 border-emerald-400" : "border-white/10"
            } ${className}`}
            style={{ width: size, height: size }}
            title={`${provider.provider_name}${isSubscribed ? " (Aboneliğiniz Var)" : ""}`}
        >
            <Image
                src={`https://image.tmdb.org/t/p/original${provider.logo_path}`}
                alt={provider.provider_name}
                fill
                className="object-cover"
                sizes={`${size}px`}
            />
            {isSubscribed && (
                <div className="absolute bottom-0 right-0 w-2 h-2 bg-emerald-500 rounded-full ring-1 ring-background" />
            )}
        </div>
    );
}
