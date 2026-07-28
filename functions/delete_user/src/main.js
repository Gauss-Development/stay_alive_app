import { Client, Users } from 'node-appwrite';

// Deletes the calling user's Appwrite auth record.
//
// The app clears the user's documents and sessions client-side, but the client
// SDK cannot delete its own auth user — that requires a server API key. This
// function performs that final step.
//
// SECURITY: the user id is taken ONLY from the authenticated execution context
// (`x-appwrite-user-id`, set by Appwrite from the caller's session) — never from
// the request body — so a session can only ever delete its own account. Set the
// function's Execute access to "Users" (any authenticated user) and nothing more.
export default async ({ req, res, log, error }) => {
  const userId = req.headers['x-appwrite-user-id'];
  if (!userId) {
    error('Refusing delete: no authenticated user in execution context');
    return res.json({ ok: false, error: 'unauthenticated' }, 401);
  }

  // Prefer the dynamic API key Appwrite injects for the execution; fall back to
  // a configured key for local/manual runs.
  const apiKey = req.headers['x-appwrite-key'] || process.env.APPWRITE_API_KEY;
  if (!apiKey) {
    error('No API key available (x-appwrite-key / APPWRITE_API_KEY)');
    return res.json({ ok: false, error: 'server_misconfigured' }, 500);
  }

  const client = new Client()
    .setEndpoint(process.env.APPWRITE_FUNCTION_API_ENDPOINT)
    .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(apiKey);

  const users = new Users(client);

  try {
    await users.delete(userId);
    log(`Deleted auth record for user ${userId}`);
    return res.json({ ok: true, userId });
  } catch (e) {
    // A missing user is an acceptable terminal state for a deletion request.
    if (e.code === 404) {
      log(`Auth record ${userId} already absent`);
      return res.json({ ok: true, userId, alreadyDeleted: true });
    }
    error(`Failed to delete user ${userId}: ${e.message}`);
    return res.json({ ok: false, error: e.message }, 500);
  }
};
