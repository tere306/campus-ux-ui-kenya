import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const ALLOWED_ORIGINS = new Set([
  "https://fancy-cranachan-c98e89.netlify.app",
  "https://azacjdyxgknfqarcemhi.supabase.co",
]);
const MAX_BODY_BYTES = 4096;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  const allowed = ALLOWED_ORIGINS.has(origin) ? origin : "";
  return {
    ...(allowed ? { "Access-Control-Allow-Origin": allowed, "Vary": "Origin" } : {}),
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

const json = (req: Request, body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: {
    ...cors(req),
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    "X-Content-Type-Options": "nosniff",
    "Referrer-Policy": "no-referrer",
    "Cross-Origin-Resource-Policy": "same-site",
  },
});

async function sha256Hex(value: string) {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return [...new Uint8Array(digest)].map(b => b.toString(16).padStart(2, "0")).join("");
}

function safeEqualHex(a: string, b: string) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

function passwordError(password: string) {
  if (password.length < 12) return "La contraseña debe tener al menos 12 caracteres.";
  if (password.length > 256) return "La contraseña es demasiado larga.";
  const classes = [/[a-z]/.test(password), /[A-Z]/.test(password), /[0-9]/.test(password), /[^A-Za-z0-9]/.test(password)].filter(Boolean).length;
  if (classes < 3) return "Usa al menos tres tipos entre minúsculas, mayúsculas, números y símbolos.";
  return "";
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return json(req, { error: "Método no permitido." }, 405);

  try {
    const contentLength = Number(req.headers.get("content-length") || 0);
    if (contentLength > MAX_BODY_BYTES) return json(req, { error: "Solicitud demasiado grande." }, 413);

    const raw = await req.text();
    if (new TextEncoder().encode(raw).byteLength > MAX_BODY_BYTES) return json(req, { error: "Solicitud demasiado grande." }, 413);
    let parsed: Record<string, unknown>;
    try { parsed = JSON.parse(raw || "{}"); }
    catch { return json(req, { error: "Solicitud no válida." }, 400); }

    const normalizedEmail = String(parsed.email || "").trim().toLowerCase();
    const normalizedCode = String(parsed.code || "").trim().toUpperCase();
    const pwd = String(parsed.password || "");

    if (!normalizedEmail || !normalizedCode || !pwd) {
      return json(req, { error: "Correo, código y contraseña son obligatorios." }, 400);
    }
    if (normalizedEmail.length > 254 || !EMAIL_RE.test(normalizedEmail)) {
      return json(req, { error: "Introduce un correo válido." }, 400);
    }
    if (!/^[A-F0-9]{24}$/.test(normalizedCode)) {
      return json(req, { error: "No se pudo validar la invitación. Revisa el código e inténtalo de nuevo." }, 400);
    }
    const pwdError = passwordError(pwd);
    if (pwdError) return json(req, { error: pwdError }, 400);

    const url = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    if (!url || !serviceKey) return json(req, { error: "Servicio temporalmente no disponible." }, 503);

    const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
    const { data: invite, error: inviteError } = await admin
      .from("student_invites")
      .select("id,email,real_name,status,activation_code_hash,activation_expires_at,activation_used_at,activation_attempts,activation_locked_until")
      .ilike("email", normalizedEmail)
      .in("status", ["pending", "sent"])
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (inviteError) return json(req, { error: "No se pudo validar la invitación." }, 500);
    if (!invite) return json(req, { error: "No se pudo validar la invitación. Revisa el correo y el código." }, 400);

    const now = Date.now();
    if (invite.activation_locked_until && new Date(invite.activation_locked_until).getTime() > now) {
      return json(req, { error: "La activación está bloqueada temporalmente por demasiados intentos. Inténtalo más tarde." }, 429);
    }
    if (!invite.activation_code_hash || !invite.activation_expires_at || new Date(invite.activation_expires_at).getTime() < now || invite.activation_used_at) {
      return json(req, { error: "El código no está disponible o ha caducado. Solicita una invitación nueva." }, 410);
    }

    const suppliedHash = await sha256Hex(normalizedCode);
    if (!safeEqualHex(suppliedHash, String(invite.activation_code_hash))) {
      const attempts = Number(invite.activation_attempts || 0) + 1;
      const patch: Record<string, unknown> = { activation_attempts: attempts };
      if (attempts >= 5) patch.activation_locked_until = new Date(now + 15 * 60 * 1000).toISOString();
      await admin.from("student_invites").update(patch).eq("id", invite.id);
      return json(req, {
        error: attempts >= 5
          ? "Código incorrecto. La activación se ha bloqueado durante 15 minutos."
          : "No se pudo validar la invitación. Revisa el correo y el código."
      }, attempts >= 5 ? 429 : 400);
    }

    const { error: createError } = await admin.auth.admin.createUser({
      email: normalizedEmail,
      password: pwd,
      email_confirm: true,
      user_metadata: { real_name: invite.real_name, activation_source: "student_invite" },
    });

    if (createError) {
      const msg = String(createError.message || "");
      if (/already|registered|exists/i.test(msg)) {
        return json(req, { error: "Ya existe una cuenta para este correo. Entra con tu contraseña o recupera el acceso." }, 409);
      }
      return json(req, { error: "No se pudo crear la cuenta. Inténtalo de nuevo o solicita una invitación nueva." }, 400);
    }

    await admin.from("student_invites").update({
      activation_used_at: new Date().toISOString(),
      activation_code_hash: null,
      activation_attempts: 0,
      activation_locked_until: null,
    }).eq("id", invite.id);

    return json(req, {
      ok: true,
      message: "Cuenta activada correctamente. Ya puedes entrar al campus."
    });
  } catch (e) {
    console.error(e);
    return json(req, { error: "Error inesperado durante la activación." }, 500);
  }
});
