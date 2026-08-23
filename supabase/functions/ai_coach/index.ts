// ai_coach — OpenAI proxy. Without OPENAI_API_KEY the client uses CoachLocalFallback.
//
// Contract (unchanged from the old Appwrite function):
//   401 unauthenticated | 400 invalid_json | 403 premium_required
//   503 llm_unavailable | 502 llm_failed   | 200 coach payload JSON
import { createClient } from 'npm:@supabase/supabase-js@2';

const SYSTEM_PROMPT = `You are «Rostok Coach» for a Daily Dozen healthy-eating habit app.
Motivate with short, concrete next steps. Never diagnose, prescribe diets as treatment,
or claim medical outcomes. Reply in the user's language (default Russian).
Always return STRICT JSON:
{
  "message": string,
  "insightCards": [{"title": string, "body": string, "emphasis"?: string}],
  "challengeDraft"?: {
    "title": string,
    "description": string,
    "target": number,
    "xpReward": number,
    "categoryId"?: string,
    "challengeType"?: string
  }
}`;

const PREMIUM_MODES = new Set(['chat', 'weeklyInsight', 'personalizeChallenge']);

Deno.serve(async (req: Request): Promise<Response> => {
  const userId = await authenticatedUserId(req);
  if (!userId) {
    return json({ ok: false, error: 'unauthenticated' }, 401);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ ok: false, error: 'invalid_json' }, 400);
  }

  const mode = typeof body.mode === 'string' && body.mode.length > 0 ? body.mode : 'nudge';
  const isPremium = Boolean(body.isPremium);
  const context = body.context ?? {};

  if (PREMIUM_MODES.has(mode) && !isPremium) {
    return json({ ok: false, error: 'premium_required' }, 403);
  }

  const apiKey = Deno.env.get('OPENAI_API_KEY');
  if (!apiKey) {
    console.log('OPENAI_API_KEY missing — client should use local fallback');
    return json({ ok: false, error: 'llm_unavailable' }, 503);
  }

  let payload: Record<string, unknown>;
  try {
    payload = await callOpenAI(apiKey, mode, context);
  } catch (e) {
    console.error(`OpenAI failed: ${(e as Error).message}`);
    return json({ ok: false, error: 'llm_failed' }, 502);
  }

  await audit(userId, mode).catch((e) =>
    console.error(`audit failed: ${(e as Error).message}`),
  );
  return json(payload);
});

async function authenticatedUserId(req: Request): Promise<string | null> {
  const authHeader = req.headers.get('Authorization');
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  if (!authHeader || !supabaseUrl || !anonKey) {
    return null;
  }
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data } = await userClient.auth.getUser();
  return data?.user?.id ?? null;
}

async function callOpenAI(
  apiKey: string,
  mode: string,
  context: unknown,
): Promise<Record<string, unknown>> {
  const model = Deno.env.get('OPENAI_MODEL') ?? 'gpt-4o-mini';
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      temperature: 0.6,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: JSON.stringify({ mode, context }) },
      ],
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`OpenAI HTTP ${response.status}: ${text}`);
  }

  const data = await response.json();
  console.log(`tokens=${data.usage?.total_tokens ?? '?'}`);
  return JSON.parse(data.choices?.[0]?.message?.content || '{}');
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function audit(userId: string, mode: string): Promise<void> {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceRoleKey) {
    return;
  }
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { error } = await admin.from('ai_interactions').insert({
    user_id: userId,
    mode,
    from_fallback: false,
  });
  if (error) {
    throw new Error(error.message);
  }
}
