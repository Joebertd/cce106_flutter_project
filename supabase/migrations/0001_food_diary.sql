-- Food Diary Supabase schema.
-- Run this migration in the Supabase SQL Editor or through Supabase CLI.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_path text,
  daily_calorie_goal integer not null default 2000 check (daily_calorie_goal > 0),
  daily_protein_goal integer not null default 100 check (daily_protein_goal >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.foods (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  image_path text,
  calories integer not null default 0 check (calories >= 0),
  protein integer not null default 0 check (protein >= 0),
  prep_time integer not null default 0 check (prep_time >= 0),
  ingredients text[] not null default '{}',
  steps text[] not null default '{}',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint foods_name_unique unique (name)
);

create table if not exists public.food_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  food_id uuid not null references public.foods(id) on delete cascade,
  quantity numeric(8,2) not null default 1 check (quantity > 0),
  meal_type text not null default 'Meal',
  eaten_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists food_logs_user_date_idx
  on public.food_logs(user_id, eaten_at desc);

alter table public.profiles enable row level security;
alter table public.foods enable row level security;
alter table public.food_logs enable row level security;

-- Expose only authenticated CRUD operations to the Data API; RLS below scopes rows.
grant usage on schema public to authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.foods to authenticated;
grant select, insert, update, delete on public.food_logs to authenticated;

-- Profiles: users can read/update only their own profile.
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select to authenticated
using (id = auth.uid());

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert to authenticated
with check (id = auth.uid());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- Foods: everyone authenticated can read; users can create their own foods.
drop policy if exists "foods_select_authenticated" on public.foods;
create policy "foods_select_authenticated"
on public.foods for select to authenticated
using (true);

drop policy if exists "foods_insert_own" on public.foods;
create policy "foods_insert_own"
on public.foods for insert to authenticated
with check (created_by = auth.uid());

drop policy if exists "foods_update_own" on public.foods;
create policy "foods_update_own"
on public.foods for update to authenticated
using (created_by = auth.uid())
with check (created_by = auth.uid());

drop policy if exists "foods_delete_own" on public.foods;
create policy "foods_delete_own"
on public.foods for delete to authenticated
using (created_by = auth.uid());

-- Food logs: users can only see/change their own diary entries.
drop policy if exists "food_logs_select_own" on public.food_logs;
create policy "food_logs_select_own"
on public.food_logs for select to authenticated
using (user_id = auth.uid());

drop policy if exists "food_logs_insert_own" on public.food_logs;
create policy "food_logs_insert_own"
on public.food_logs for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "food_logs_update_own" on public.food_logs;
create policy "food_logs_update_own"
on public.food_logs for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "food_logs_delete_own" on public.food_logs;
create policy "food_logs_delete_own"
on public.food_logs for delete to authenticated
using (user_id = auth.uid());

-- Create profile automatically whenever a Supabase Auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Storage buckets.
insert into storage.buckets (id, name, public)
values ('food-images', 'food-images', true)
on conflict (id) do update set public = true;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

-- Storage RLS. Paths are user-id-prefixed for writes.
drop policy if exists "food_images_read_authenticated" on storage.objects;
create policy "food_images_read_authenticated"
on storage.objects for select to authenticated
using (bucket_id = 'food-images');

drop policy if exists "food_images_insert_own_folder" on storage.objects;
create policy "food_images_insert_own_folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'food-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "food_images_update_own_folder" on storage.objects;
create policy "food_images_update_own_folder"
on storage.objects for update to authenticated
using (
  bucket_id = 'food-images'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'food-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "food_images_delete_own_folder" on storage.objects;
create policy "food_images_delete_own_folder"
on storage.objects for delete to authenticated
using (
  bucket_id = 'food-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "avatars_read_authenticated" on storage.objects;
create policy "avatars_read_authenticated"
on storage.objects for select to authenticated
using (bucket_id = 'avatars');

drop policy if exists "avatars_insert_own_folder" on storage.objects;
create policy "avatars_insert_own_folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "avatars_update_own_folder" on storage.objects;
create policy "avatars_update_own_folder"
on storage.objects for update to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "avatars_delete_own_folder" on storage.objects;
create policy "avatars_delete_own_folder"
on storage.objects for delete to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Seed the original 9 recipes. Images remain bundled as fallbacks;
-- newly uploaded images use Supabase Storage.
insert into public.foods
  (name, description, image_path, calories, protein, prep_time, ingredients, steps)
values
('Spaghetti Bolognese','A classic Italian meat sauce served over pasta',null,650,35,60,
 ARRAY['spaghetti','ground beef','onions','tomato sauce','red wine'],
 ARRAY['Cook the spaghetti according to package directions.','Brown the ground beef and onions.','Add the tomato sauce and red wine and simmer for 1 hour.','Toss with cooked spaghetti and serve.']),
('Chicken Parmesan','Breaded chicken breast topped with tomato sauce and mozzarella',null,550,45,30,
 ARRAY['chicken breasts','breadcrumbs','parmesan','tomato sauce','mozzarella'],
 ARRAY['Bread chicken breasts with breadcrumbs.','Pan fry until golden brown.','Top with tomato sauce and mozzarella.','Bake until cheese is melted.']),
('Caesar Salad','Romaine lettuce with creamy Caesar dressing, croutons and parmesan',null,250,10,10,
 ARRAY['romaine lettuce','caesar dressing','croutons','parmesan'],
 ARRAY['Chop romaine lettuce.','Toss with caesar dressing.','Top with croutons and parmesan.']),
('Tacos','Soft tortilla shells filled with seasoned ground beef, lettuce, cheese and salsa',null,500,20,20,
 ARRAY['tortillas','ground beef','lettuce','cheese','salsa'],
 ARRAY['Cook ground beef with taco seasoning.','Warm tortillas.','Fill with beef, lettuce, cheese and salsa.']),
('Pasta Alfredo','Fettuccine pasta tossed in a rich, creamy parmesan cheese sauce',null,800,15,15,
 ARRAY['fettuccine','butter','cream','parmesan'],
 ARRAY['Cook pasta according to package directions.','Melt butter in a pan.','Add cream and parmesan and cook until thick and creamy.','Toss pasta with sauce.']),
('Cheese Pizza','Crispy crust with tomato sauce and mozzarella cheese',null,700,20,40,
 ARRAY['pizza dough','tomato sauce','mozzarella'],
 ARRAY['Stretch dough into rounds.','Top with sauce and cheese.','Bake until crust is crispy and cheese melted.']),
('Hamburger','Juicy beef patty with lettuce, tomato, onion and cheese on a bun',null,650,25,15,
 ARRAY['ground beef','hamburger buns','lettuce','tomato','onion','cheese'],
 ARRAY['Form ground beef into patties and grill.','Toast buns.','Place patty on bun and top with lettuce, tomato, onion and cheese.']),
('Chocolate Chip Cookies','Chewy cookies filled with chocolate chips',null,200,3,30,
 ARRAY['flour','butter','sugar','eggs','chocolate chips'],
 ARRAY['Cream butter and sugar.','Beat in eggs.','Stir in flour and chocolate chips.','Scoop dough and bake.']),
('Chicken Fried Rice','Rice stir-fried with chicken, vegetables and egg',null,450,25,30,
 ARRAY['rice','chicken','vegetables','egg','soy sauce'],
 ARRAY['Cook rice.','Stir fry chicken and vegetables.','Add rice and stir fry.','Scramble egg and mix in.','Season with soy sauce.'])
on conflict do nothing;
