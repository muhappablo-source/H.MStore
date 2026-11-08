-- H.M STORE custom order requests
create extension if not exists pgcrypto;
create table if not exists public.custom_requests (
 id uuid primary key default gen_random_uuid(),
 request_code text not null unique check (request_code ~ '^[A-F0-9]{12}$'),
 customer_name text not null check (char_length(customer_name) between 1 and 80),
 customer_phone text not null check (char_length(customer_phone) between 6 and 25),
 product_type text not null check (product_type in ('بوستر','فريم','بدون فريم')),
 quantity integer not null check (quantity between 1 and 30),
 details text not null default '' check (char_length(details) <= 1200),
 image_url text not null,
 status text not null default 'pending' check (status in ('pending','approved','rejected')),
 admin_note text not null default '',
 created_at timestamptz not null default now()
);
alter table public.custom_requests enable row level security;
drop policy if exists "Public can submit custom requests" on public.custom_requests;
create policy "Public can submit custom requests" on public.custom_requests for insert to anon with check (status='pending' and admin_note='');
drop policy if exists "Admins manage custom requests" on public.custom_requests;
create policy "Admins manage custom requests" on public.custom_requests for all to authenticated using (exists(select 1 from public.store_admins a where a.user_id=auth.uid())) with check (exists(select 1 from public.store_admins a where a.user_id=auth.uid()));
create or replace function public.get_custom_request_status(p_request_code text)
returns table(status text, product_type text, quantity integer, details text)
language sql security definer set search_path=public
as $$ select r.status,r.product_type,r.quantity,r.details from public.custom_requests r where r.request_code=p_request_code and p_request_code ~ '^[A-F0-9]{12}$' limit 1 $$;
revoke all on function public.get_custom_request_status(text) from public;
grant execute on function public.get_custom_request_status(text) to anon, authenticated;
grant insert on public.custom_requests to anon;
grant select,update,delete on public.custom_requests to authenticated;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('custom-order-images','custom-order-images',true,5242880,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict(id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp','image/gif'];
drop policy if exists "Anyone uploads custom request images" on storage.objects;
create policy "Anyone uploads custom request images" on storage.objects for insert to anon with check (bucket_id='custom-order-images');
drop policy if exists "Admins delete custom request images" on storage.objects;
create policy "Admins delete custom request images" on storage.objects for delete to authenticated using (bucket_id='custom-order-images' and exists(select 1 from public.store_admins a where a.user_id=auth.uid()));

-- Product categories managed from the admin dashboard
create table if not exists public.store_categories (
 id uuid primary key default gen_random_uuid(),
 name text not null unique check (char_length(name) between 1 and 40),
 created_at timestamptz not null default now()
);
alter table public.store_categories enable row level security;
drop policy if exists "Public can view store categories" on public.store_categories;
create policy "Public can view store categories" on public.store_categories for select to anon, authenticated using (true);
drop policy if exists "Admins manage store categories" on public.store_categories;
create policy "Admins manage store categories" on public.store_categories for all to authenticated
using (exists(select 1 from public.store_admins a where a.user_id=auth.uid()))
with check (exists(select 1 from public.store_admins a where a.user_id=auth.uid()));
grant select on public.store_categories to anon, authenticated;
grant insert,update,delete on public.store_categories to authenticated;
insert into public.store_categories(name) values ('بوسترات'),('مطبوعات') on conflict(name) do nothing;
