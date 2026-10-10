# Food Diary — Flutter + Supabase deployment

## 1. What was rebuilt

The supplied ZIP contains an APK, screenshots, recipe JSON and images, but not the original Dart/Flutter source. This project therefore recreates the app's main flows from those references:

- Email/password authentication with Supabase Auth
- Automatic user profile creation
- Home nutrition dashboard
- Recipe/food catalogue
- Food detail and daily diary logging
- Food history
- Add-food form
- Food image upload to Supabase Storage
- Profile/avatar upload to Supabase Storage
- Daily calorie/protein goals
- Row Level Security for user-owned data

## 2. Create/configure Supabase

Create a Supabase project, then run:

`supabase/migrations/0001_food_diary.sql`

in the Supabase SQL Editor.

The migration creates:

- `profiles`
- `foods`
- `food_logs`
- `food-images` Storage bucket
- `avatars` Storage bucket
- RLS policies
- automatic profile trigger
- the original 9 recipes

Supabase's Flutter quickstart recommends `supabase_flutter`, initialization with the project URL and publishable key, and RLS for production client access.

## 3. Enable Google SSO

Google sign-in is available from the login screen through Supabase Auth. In the Supabase dashboard:

1. Open **Authentication → Providers**.
2. Enable **Google** and enter the Google OAuth client ID and secret.
3. In Google Cloud Console, add this authorized redirect URI:
   `https://YOUR_PROJECT_REF.supabase.co/auth/callback`
4. In Supabase, set the Google provider's callback URL to:
   `https://YOUR_PROJECT_REF.supabase.co/auth/callback`
5. The Flutter app uses the current web origin as the final redirect target. For local development, add the exact origin such as `http://localhost:54000/` to the Supabase provider's redirect settings when the app is hosted outside the default development URL.
6. Save the provider configuration and restart the Flutter web app.

> Google does not authorize the Flutter app origin directly. Google authorizes Supabase's `/auth/callback`, and Supabase redirects the user back to the Flutter origin after authentication.

## 4. Localhost / Chrome

Install Flutter, then from this directory:

`flutter pub get`

Run:

`flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY`

The app will open on a local Flutter web development URL. Add that exact URL, including its port, to Google and Supabase OAuth redirect settings.

Or use:

`.\scripts\run_local.ps1 -SupabaseUrl "https://YOUR_PROJECT.supabase.co" -SupabasePublishableKey "YOUR_KEY"`

## 5. Android

Run:

`flutter create .`

if the Android platform directory has not yet been generated.

Then:

`flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`

The original APK is retained only as a reference artifact; it is not the source of the new app.

## 5. Web deployment

Build:

`flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`

Deploy the generated `build/web` directory to a static Flutter-compatible host such as Firebase Hosting, Netlify, Vercel, Cloudflare Pages, or your own web server.

Supabase is the backend/database/auth/object-storage layer. It is not necessary to put the Flutter web build itself inside the Supabase database/storage bucket.

## 6. Security

Use only the Supabase publishable/anon client key in the Flutter application. Never embed the `service_role` secret in Flutter.

The database and Storage policies in the migration are designed so authenticated users can only modify their own profiles, diary entries, and uploaded object folders.

Before production, review the policies in the Supabase dashboard and configure Auth email settings / redirect URLs for the final domain.
