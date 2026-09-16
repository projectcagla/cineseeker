import { Resend } from "resend";
import { getCloudflareContext } from "@opennextjs/cloudflare";

function setting(name: "RESEND_API_KEY" | "RESEND_FROM_EMAIL"): string {
    try {
        const { env } = getCloudflareContext();
        const value = (env as unknown as Record<string, unknown>)[name];
        if (typeof value === "string" && value.trim()) return value.trim();
    } catch { /* Local Next.js development uses environment variables. */ }
    return (process.env[name] || "").trim();
}
function escapeHTML(value: string) {
    return value.replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);
}
async function sendActionEmail(to: string, url: string, subject: string, action: string) {
    const key = setting("RESEND_API_KEY"), from = setting("RESEND_FROM_EMAIL");
    if (!key || key.startsWith("re_your_") || !from) throw new Error("E-posta servisi yapılandırılmadı.");
    const result = await new Resend(key).emails.send({
        from, to, subject,
        text: `${action}: ${url}\nBu işlemi siz başlatmadıysanız bu e-postayı yok sayabilirsiniz.`,
        html: `<div style="font-family:system-ui;max-width:600px;padding:24px;background:#0a0a0a;color:#ededed"><h1 style="color:#ff7a29">CineSeeker</h1><p>${escapeHTML(subject)}</p><p><a href="${escapeHTML(url)}" style="color:#ffad42">${escapeHTML(action)}</a></p><p>Bu işlemi siz başlatmadıysanız bu e-postayı yok sayabilirsiniz.</p></div>`,
    });
    // Never log verification/reset links or pretend delivery succeeded.
    if (result.error) throw new Error("E-posta gönderilemedi. Lütfen tekrar deneyin.");
}
export async function sendVerificationEmail({ to, url }: { to: string; url: string }) {
    await sendActionEmail(to, url, "CineSeeker - E-posta adresinizi doğrulayın", "E-posta adresimi doğrula");
}
export async function sendPasswordResetEmail({ to, url }: { to: string; url: string }) {
    await sendActionEmail(to, url, "CineSeeker - Şifre sıfırlama talebi", "Yeni şifre belirle");
}
