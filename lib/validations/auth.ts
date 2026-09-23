import { z } from "zod";

export const registerSchema = z.object({
    name: z.string().trim().min(2, "İsim en az 2 karakter olmalıdır").max(50, "İsim en fazla 50 karakter olabilir"),
    email: z.string().trim().email("Geçerli bir e-posta adresi giriniz"),
    password: z.string().min(8, "Şifre en az 8 karakter olmalıdır").max(100, "Şifre çok uzun"),
});

export const loginSchema = z.object({
    email: z.string().trim().email("Geçerli bir e-posta adresi giriniz"),
    password: z.string().min(1, "Şifre giriniz"),
});

export const forgotPasswordSchema = z.object({
    email: z.string().trim().email("Geçerli bir e-posta adresi giriniz"),
});

export const resetPasswordSchema = z.object({
    password: z.string().min(8, "Şifre en az 8 karakter olmalıdır").max(100, "Şifre çok uzun"),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
