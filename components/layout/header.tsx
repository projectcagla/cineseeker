import { SearchBar } from "../features/search-bar";
import { UserNav } from "./user-nav";
import Link from "next/link";
import Image from "next/image";
import { Suspense } from "react";

export function Header() {
    return (
        <header className="sticky top-0 z-50 w-full backdrop-blur-lg bg-background/80 border-b border-white/5 supports-[backdrop-filter]:bg-background/60">
            <div className="container mx-auto px-4 h-16 flex items-center justify-between gap-4">
                <Link href="/" className="shrink-0" aria-label="CineSeeker ana sayfa">
                    <Image src="/brand/wordmark.svg" alt="CineSeeker" width={154} height={39} priority className="w-28 sm:w-[154px] h-auto" />
                </Link>
                <div className="flex-1 max-w-xl">
                    <Suspense fallback={<div className="h-10 w-full bg-muted/50 rounded-xl animate-pulse" />}>
                        <SearchBar />
                    </Suspense>
                </div>
                <UserNav />
            </div>
        </header>
    );
}
