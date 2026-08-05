import { Client, Databases, ID } from 'node-appwrite';

/**
 * AI Coach Appwrite Function — OpenAI proxy only.
 * Without OPENAI_API_KEY the client uses CoachLocalFallback.
 */
const SYSTEM_PROMPT = `You are «Rostok Coach» for a Daily Dozen healthy-eating habit app.
Motivate with short, concrete next steps. Never diagnose, prescribe diets as treatment,
or claim medical outcomes. Reply in the user's language (default Russian).
Always return STRICT JSON:
{
  "message": string,
  "suggestedActions": string[],
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

export default async ({ req, res, log, error }) => {
  const userId = req.headers['x-appwrite-user-id'];
  if (!userId) {
    return res.json({ ok: false, error: 'unauthenticated' }, 401);
  }

  let body = {};
  try {
    body = typeof req.body === 'string' ? JSON.parse(req.body || '{}') : req.body || {};
  } catch {
    return res.json({ ok: false, error: 'invalid_json' }, 400);
  }

  const mode = body.mode || 'nudge';
  const isPremium = Boolean(body.isPremium);
  const context = body.context || {};

  const premiumModes = new Set(['chat', 'weeklyInsight', 'personalizeChallenge']);
  if (premiumModes.has(mode) && !isPremium) {
    return res.json({ ok: false, error: 'premium_required' }, 403);
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    log('OPENAI_API_KEY missing — client should use local fallback');
    return res.json({ ok: false, error: 'llm_unavailable' }, 503);
  }

  let payload;
  try {
    payload = await callOpenAI({ apiKey, mode, context, log });
  } catch (e) {
    error(`OpenAI failed: ${e.message}`);
    return res.json({ ok: false, error: 'llm_failed' }, 502);
  }

  await audit(req, userId, mode).catch((e) => error(`audit failed: ${e.message}`));
  return res.json(payload);
};

async function callOpenAI({ apiKey, mode, context, log }) {
  const model = process.env.OPENAI_MODEL || 'gpt-4o-mini';
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
  log(`tokens=${data.usage?.total_tokens ?? '?'}`);
  return JSON.parse(data.choices?.[0]?.message?.content || '{}');
}

async function audit(req, userId, mode) {
  const collectionId = process.env.APPWRITE_AI_INTERACTIONS_COLLECTION_ID;
  const databaseId = process.env.APPWRITE_DATABASE_ID;
  if (!collectionId || !databaseId) {
    return;
  }

  const apiKey = req.headers['x-appwrite-key'] || process.env.APPWRITE_API_KEY;
  if (!apiKey) {
    return;
  }

  const client = new Client()
    .setEndpoint(process.env.APPWRITE_FUNCTION_API_ENDPOINT)
    .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(apiKey);

  const databases = new Databases(client);
  await databases.createDocument(databaseId, collectionId, ID.unique(), {
    user_id: userId,
    mode,
    created_at: new Date().toISOString(),
    from_fallback: false,
  });
}
