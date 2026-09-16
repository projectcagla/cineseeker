import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
const { send } = vi.hoisted(() => ({ send: vi.fn() }));
vi.mock("resend", () => ({ Resend: class { emails = { send }; } }));
vi.mock("@opennextjs/cloudflare", () => ({ getCloudflareContext: () => { throw new Error("local test"); } }));
import { sendVerificationEmail, sendPasswordResetEmail } from "../lib/email";
describe("account email delivery", () => {
  beforeEach(() => {
    send.mockReset();
    vi.stubEnv("RESEND_API_KEY", "test-api-key");
    vi.stubEnv("RESEND_FROM_EMAIL", "CineSeeker <mail@example.com>");
  });
  afterEach(() => vi.unstubAllEnvs());
  it("fails explicitly when the sender is not configured", async () => {
    vi.stubEnv("RESEND_FROM_EMAIL", "");
    await expect(sendVerificationEmail({ to: "user@example.com", url: "https://example.com/verify" })).rejects.toThrow("yapılandırılmadı");
    expect(send).not.toHaveBeenCalled();
  });
  it("propagates provider delivery failure instead of claiming success", async () => {
    send.mockResolvedValue({ error: { message: "provider error" } });
    await expect(sendPasswordResetEmail({ to: "user@example.com", url: "https://example.com/reset" })).rejects.toThrow("gönderilemedi");
  });
  it("uses the configured verified sender and escapes URLs in HTML", async () => {
    send.mockResolvedValue({ data: { id: "delivery" }, error: null });
    await sendVerificationEmail({ to: "user@example.com", url: 'https://example.com/verify?a=1&b="x"' });
    expect(send).toHaveBeenCalledWith(expect.objectContaining({ from: "CineSeeker <mail@example.com>", html: expect.stringContaining("&amp;b=&quot;x&quot;") }));
  });
});
