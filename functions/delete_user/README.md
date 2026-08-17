# delete_user Appwrite Function

Completes account deletion by removing the caller's **Appwrite auth record**.
The app deletes the user's documents and sessions client-side
(`AppwriteAuthRemoteDataSource.deleteAccount`), but the client SDK cannot delete
its own auth user — that requires a server API key. Both Apple and Google
require full account deletion, so this function is a store-release blocker.

## Contract

- **Trigger:** HTTP execution from the app via `Functions.createExecution`.
- **Identity:** user id is read from `x-appwrite-user-id` (the authenticated
  execution context). The request body is ignored, so a session can only delete
  its own account.
- **Action:** `users.delete(userId)`. A 404 (already gone) is treated as success.
- **Response:** `{ ok: true, userId }` on success; `{ ok: false, error }` with a
  4xx/5xx status otherwise. The client throws on any non-2xx `completed` result.

## Deployment

```bash
appwrite functions create \
  --function-id delete_user --name "delete_user" \
  --runtime node-22 --execute '["users"]'   # any authenticated user, nothing wider

appwrite functions create-deployment \
  --function-id delete_user --entrypoint "src/main.js" \
  --code functions/delete_user --activate true
```

Runtime env: `APPWRITE_FUNCTION_API_ENDPOINT` and `APPWRITE_FUNCTION_PROJECT_ID`
are provided automatically. The API key comes from the dynamic `x-appwrite-key`
header — enable a **dynamic API key** with scope `users.write` on the function
(or set `APPWRITE_API_KEY` for manual runs).

After deploy, put the function id into the app config:

```
APPWRITE_DELETE_USER_FUNCTION_ID=delete_user
```

(`assets/env/app.env` for local, `scripts/release.env` / CI `--dart-define` for
release). When unset, the app logs a warning and skips auth-record deletion
(dev fallback only — **not** store-compliant).
