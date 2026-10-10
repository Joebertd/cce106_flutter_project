# Supabase backend

Run `migrations/0001_food_diary.sql` in your Supabase SQL Editor.

The migration grants the authenticated role the Data API permissions it needs;
the RLS policies below those grants still restrict access to each user's rows.
If this migration was applied before those grants were added, rerun the updated
SQL. If the Data API reports `PGRST205`, verify that `public` is exposed to the
Data API in project settings, then refresh the schema cache or rerun the SQL.

The Flutter app uses:
- Auth: email/password
- Postgres: profiles, foods, food_logs
- Storage: food-images and avatars
- RLS: authenticated access with user ownership
