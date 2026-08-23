// delete_user — deletes the calling user's auth record (account-deletion compliance).
//
// Identity comes from the caller's JWT (the gateway enforces verify_jwt, and we
// re-derive the user here — a session can only ever delete itself). Row cleanup
// is handled entirely by `on delete cascade` from auth.users, so this function
// deletes nothing else.
import { createClient } from 'npm:@supabase/supabase-js@2';

Deno.serve(async (req: Request): Promise<Response> => {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return json({ ok: false, error: 'unauthenticated' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return json({ ok: false, error: 'server_misconfigured' }, 500);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data, error: userError } = await userClient.auth.getUser();
  const userId = data?.user?.id;
  if (userError || !userId) {
    return json({ ok: false, error: 'unauthenticated' }, 401);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { error } = await admin.auth.admin.deleteUser(userId);
  if (error) {
    // Parity with the old function: a user that is already gone is a success.
    if (error.status === 404) {
      return json({ ok: true, userId, alreadyDeleted: true });
    }
    console.error(`delete_user failed for ${userId}: ${error.message}`);
    return json({ ok: false, error: error.message }, 500);
  }

  return json({ ok: true, userId });
});

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
