import { z } from "zod";
export const catalogQuery = z.object({
  action: z.enum(["discover", "search", "detail", "providers", "genres", "arrivals"]),
  media: z.enum(["movie", "tv"]).default("movie"),
  id: z.coerce.number().int().positive().optional(),
  page: z.coerce.number().int().min(1).max(500).default(1),
  query: z.string().trim().max(150).default(""),
  providers: z.string().regex(/^\d+(\|\d+)*$/).max(300).optional(),
  genre: z.coerce.number().int().positive().optional(),
}).superRefine((value, ctx) => {
  if (value.action === "detail" && !value.id) ctx.addIssue({ code: "custom", message: "ID required", path: ["id"] });
});
