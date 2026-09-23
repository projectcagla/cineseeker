import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Header } from "@/components/layout/header";
import { Footer } from "@/components/layout/footer";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "CineSeeker | Nerede İzlenir?",
  description: "Türkiye'de hangi film hangi platformda? Netflix, Prime, Disney+ ve fazlası.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="tr" className="dark">
      <body className={`${inter.className} min-h-screen bg-background text-foreground tracking-tight flex flex-col justify-between`}>
        <div>
          <Header />
          <main className="container mx-auto px-4 py-8">
            {children}
          </main>
        </div>
        <Footer />
      </body>
    </html>
  );
}
