import { SearchBar } from "../features/search-bar";
import Link from "next/link";
import { Suspense } from "react";

export function Header() {
    return (
        <header className="sticky top-0 z-50 w-full backdrop-blur-lg bg-background/80 border-b border-white/5 supports-[backdrop-filter]:bg-background/60">
            <div className="container mx-auto px-4 h-16 flex items-center justify-between gap-4">
                <Link href="/" className="font-bold text-xl tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-primary to-orange-500 shrink-0">
                    CINESEEKER
                </Link>
                <div className="flex-1 max-w-xl">
                    <Suspense fallback={<div className="h-10 w-full bg-muted/50 rounded-xl animate-pulse" />}>
                        <SearchBar />
                    </Suspense>
                </div>
                <div className="w-8 shrink-0" /> {/* Spacer for balance if needed */}
            </div>
        </header>
    );
}
