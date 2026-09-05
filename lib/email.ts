import { Resend } from "resend";
import { getCloudflareContext } from "@opennextjs/cloudflare";

function getResendApiKey(): string {
    try {
        const { env } = getCloudflareContext();
        const cfEnv = env as unknown as { RESEND_API_KEY?: string };
        if (cfEnv?.RESEND_API_KEY) return cfEnv.RESEND_API_KEY;
    } catch {
        // Fallback for build time or local node
    }
    return process.env.RESEND_API_KEY || "";
}

export async function sendVerificationEmail({ to, url }: { to: string; url: string }) {
    const apiKey = getResendApiKey();
    if (!apiKey || apiKey === "re_your_resend_api_key_here") {
        console.log(`[Email Service Mock] Doğrulama linki: ${url}`);
        return;
    }

    try {
        const resend = new Resend(apiKey);
        await resend.emails.send({
            from: "CineSeeker <noreply@cineseeker.com>",
            to,
            subject: "CineSeeker - E-posta Adresinizi Doğrulayın",
            html: `
                <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; background-color: #0a0a0a; color: #ededed; border-radius: 12px; border: 1px solid #262626;">
                    <h1 style="color: #e50914; font-size: 24px; margin-bottom: 16px;">CineSeeker'a Hoş Geldiniz</h1>
                    <p style="line-height: 1.6; color: #a3a3a3;">Hesabınızı güvenli bir şekilde aktifleştirmek için lütfen aşağıdaki butona tıklayın:</p>
                    <div style="margin: 32px 0;">
                        <a href="${url}" style="background-color: #e50914; color: #ffffff; padding: 12px 28px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
                            E-posta Adresimi Doğrula
                        </a>
                    </div>
                    <p style="color: #737373; font-size: 13px;">Bu işlemi siz başlatmadıysanız bu e-postayı güvenle yok sayabilirsiniz.</p>
                </div>
            `,
        });
    } catch (error) {
        console.error("[Email] Doğrulama e-postası gönderilemedi:", error instanceof Error ? error.message : "Unknown error");
    }
}

export async function sendPasswordResetEmail({ to, url }: { to: string; url: string }) {
    const apiKey = getResendApiKey();
    if (!apiKey || apiKey === "re_your_resend_api_key_here") {
        console.log(`[Email Service Mock] Şifre sıfırlama linki: ${url}`);
        return;
    }

    try {
        const resend = new Resend(apiKey);
        await resend.emails.send({
            from: "CineSeeker <noreply@cineseeker.com>",
            to,
            subject: "CineSeeker - Şifre Sıfırlama Talebi",
            html: `
                <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; background-color: #0a0a0a; color: #ededed; border-radius: 12px; border: 1px solid #262626;">
                    <h1 style="color: #e50914; font-size: 24px; margin-bottom: 16px;">Şifrenizi Sıfırlayın</h1>
                    <p style="line-height: 1.6; color: #a3a3a3;">CineSeeker hesabınız için şifre sıfırlama talebinde bulundunuz:</p>
                    <div style="margin: 32px 0;">
                        <a href="${url}" style="background-color: #e50914; color: #ffffff; padding: 12px 28px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
                            Yeni Şifre Belirle
                        </a>
                    </div>
                    <p style="color: #737373; font-size: 13px;">Bu talebi siz yapmadıysanız hesabınız güvendedir, hiçbir işlem yapmanıza gerek yoktur.</p>
                </div>
            `,
        });
    } catch (error) {
        console.error("[Email] Şifre sıfırlama e-postası gönderilemedi:", error instanceof Error ? error.message : "Unknown error");
    }
}
