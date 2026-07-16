## CATEGORY 6: Supabase Security
> Type: posture · Groups: modern-stack · CWE: CWE-862

### Detection
- `@supabase/supabase-js`, `@supabase/ssr` imports
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` environment variables
- Supabase migration files in `supabase/migrations/`

### What to Search For
- Tables without RLS in migrations
- Service role key in client code
- Service role in NEXT_PUBLIC variables
- RLS policies using just true

### Actually Vulnerable
- CREATE TABLE without matching RLS enablement
- Service role key passed to client-side code
- Service role key in public environment variables
- RLS policies that allow everything

### NOT Vulnerable
- Tables with RLS enabled and real policies
- Service role in server-only code
- Anon key in client code (expected)
- Intentionally public tables

### Context Check
1. Does each table have matching RLS?
2. Do RLS policies actually restrict access?
3. Is service role key server-side only?

### Evidence Chain
- The config/code snippet quoted at file:line: the `CREATE TABLE` without a matching `ENABLE ROW LEVEL SECURITY`, the permissive `USING (true)` policy, or the service-role-key reference in client code / `NEXT_PUBLIC_` env
- For missing-RLS findings: all migrations searched for the enable statement and none found for that table (name the search)
- The reachability/impact link: what the table holds or what the exposed key can do — an anon-key client can read/write the unprotected table; a leaked service role key bypasses RLS entirely
- For key-exposure findings: why the code is client-side (component/bundle path, `NEXT_PUBLIC_` prefix, `"use client"` directive)

### Confidence Scoring
- **High** — unambiguous config: table created in migrations with no RLS-enable statement anywhere, `USING (true)` policy on a user-data table, or `SUPABASE_SERVICE_ROLE_KEY` in a `NEXT_PUBLIC_` variable or client bundle
- **Medium** — pattern present but context partial: RLS could be enabled outside migrations (dashboard), or the table's public/private intent is unclear, or the key's client reachability isn't fully confirmed
- **Low** — cannot determine whether the table is intentionally public or whether policies exist outside the repo → tag `needs human verification`

### Files to Check
- `supabase/migrations/**`, `supabase/seed.sql`
- `lib/supabase*.ts`, `utils/supabase*.ts`
- `.env*`, `next.config.*`
