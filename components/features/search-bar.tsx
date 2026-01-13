"use client";

import { useDebounce } from "@/lib/hooks";
import { Search } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";

export function SearchBar() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const initialQuery = searchParams.get("q") || "";

    const [query, setQuery] = useState(initialQuery);
    const debouncedQuery = useDebounce(query, 500);

    useEffect(() => {
        if (debouncedQuery === initialQuery) return;

        if (debouncedQuery.trim()) {
            router.push(`/search?q=${encodeURIComponent(debouncedQuery)}`);
        } else if (initialQuery) {
            router.push("/");
        }
    }, [debouncedQuery, router, initialQuery]);

    return (
        <div className="relative w-full max-w-lg mx-auto">
            <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Search className="h-5 w-5 text-muted-foreground group-focus-within:text-primary transition-colors" />
                </div>
                <input
                    type="text"
                    className="block w-full pl-10 pr-4 py-3 bg-muted/50 border border-transparent rounded-xl leading-5 placeholder-muted-foreground focus:outline-none focus:bg-background focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all sm:text-sm"
                    placeholder="Film veya dizi ara..."
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                />
            </div>
        </div>
    );
}
