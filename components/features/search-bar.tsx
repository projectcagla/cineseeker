"use client";

import { useDebounce } from "@/lib/hooks";
import { Search } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { FormEvent, useEffect, useState } from "react";

export function SearchBar() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const urlQuery = searchParams.get("q") || "";

    const [query, setQuery] = useState(urlQuery);
    const debouncedQuery = useDebounce(query, 500);

    // P0.4 FIX: Synchronize URL changes to state (e.g. browser Back / Forward buttons)
    useEffect(() => {
        setQuery(urlQuery);
    }, [urlQuery]);

    // P0.4 FIX: Use router.replace instead of router.push to avoid the back-button history trap
    useEffect(() => {
        const trimmedDebounced = debouncedQuery.trim();
        const trimmedUrl = urlQuery.trim();

        if (trimmedDebounced === trimmedUrl) return;

        if (trimmedDebounced) {
            router.replace(`/search?q=${encodeURIComponent(trimmedDebounced)}`);
        } else if (trimmedUrl) {
            router.replace("/");
        }
    }, [debouncedQuery, router, urlQuery]);

    // P0.4 FIX: Explicit form submit with preventDefault and replace
    const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        const trimmed = query.trim();
        if (trimmed) {
            router.replace(`/search?q=${encodeURIComponent(trimmed)}`);
        } else {
            router.replace("/");
        }
    };

    return (
        <form onSubmit={handleSubmit} role="search" className="relative w-full max-w-lg mx-auto">
            <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Search className="h-5 w-5 text-muted-foreground group-focus-within:text-primary transition-colors" />
                </div>
                <input
                    type="search"
                    className="block w-full pl-10 pr-4 py-3 bg-muted/50 border border-transparent rounded-xl leading-5 placeholder-muted-foreground focus:outline-none focus:bg-background focus:ring-2 focus:ring-primary/50 focus:border-primary transition-all sm:text-sm"
                    placeholder="Film veya dizi ara..."
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                />
            </div>
        </form>
    );
}
