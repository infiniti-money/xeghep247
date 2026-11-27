-- Draft schema for a fresh database. Validate against a local Supabase instance
-- and generate a versioned migration before applying to a hosted project.
begin;
create schema if not exists extensions;
create extension if not exists postgis with schema extensions;
create extension if not exists btree_gist with schema extensions;
set local search_path = public, extensions, pg_catalog;

create table public.users (
 id uuid primary key references auth.users(id) on delete restrict,
 full_name text not null check(length(trim(full_name)) between 1 and 120),
 phone text check(phone is null or phone ~ '^\+[1-9][0-9]{7,14}$'),
 role text not null default 'shipper' check(role in ('shipper','passenger','driver','admin')),
 is_verified boolean not null default false,
 rating numeric(3,2) check(rating between 0 and 5),
 created_at timestamptz not null default now()
);
create table public.vehicles (
 id uuid primary key default gen_random_uuid(),
 driver_id uuid not null references public.users(id),
 license_plate text not null unique check(length(trim(license_plate)) between 3 and 20),
 vehicle_type text not null,
 max_weight_kg numeric(12,2) not null default 0 check(max_weight_kg between 0 and 100000),
 max_volume_m3 numeric(10,3) not null default 0 check(max_volume_m3 between 0 and 1000),
 passenger_seats integer not null default 0 check(passenger_seats between 0 and 100),
 passenger_eligible boolean not null default false,
 unique(id,driver_id)
);
create table public.trips (
 id uuid primary key default gen_random_uuid(),
 driver_id uuid not null references public.users(id),
 vehicle_id uuid not null,
 foreign key(vehicle_id,driver_id) references public.vehicles(id,driver_id),
 service_type text not null check(service_type in ('cargo','passenger','tourism')),
 origin_address text not null,
 origin_lat double precision not null check(origin_lat between -90 and 90),
 origin_lng double precision not null check(origin_lng between -180 and 180),
 dest_address text not null,
 dest_lat double precision not null check(dest_lat between -90 and 90),
 dest_lng double precision not null check(dest_lng between -180 and 180),
 route_polyline geometry(LineString,4326) not null,
 departure_time timestamptz not null,
 estimated_arrival_time timestamptz not null check(estimated_arrival_time > departure_time),
 available_weight_kg numeric(12,2) not null default 0 check(available_weight_kg between 0 and 100000),
 available_volume_m3 numeric(10,3) not null default 0 check(available_volume_m3 between 0 and 1000),
 available_seats integer not null default 0 check(available_seats between 0 and 100),
 status text not null default 'open' check(status in ('open','in_progress','completed','cancelled')),
 check(not ST_IsEmpty(route_polyline) and ST_IsValid(route_polyline) and ST_NPoints(route_polyline)>=2 and ST_Length(route_polyline)>0),
 check((service_type='cargo' and available_seats=0) or
       (service_type in ('passenger','tourism') and available_weight_kg=0 and available_volume_m3=0)),
 unique(id,service_type)
);
create table public.orders (
 id uuid primary key default gen_random_uuid(),
 shipper_id uuid not null references public.users(id),
 trip_id uuid,
 service_type text not null default 'cargo' check(service_type='cargo'),
 foreign key(trip_id,service_type) references public.trips(id,service_type),
 pickup_lat double precision not null check(pickup_lat between -90 and 90),
 pickup_lng double precision not null check(pickup_lng between -180 and 180),
 pickup_address text not null,
 dropoff_lat double precision not null check(dropoff_lat between -90 and 90),
 dropoff_lng double precision not null check(dropoff_lng between -180 and 180),
 dropoff_address text not null,
 pickup_from timestamptz not null,
 pickup_until timestamptz not null check(pickup_until >= pickup_from),
 weight_kg numeric(12,2) not null check(weight_kg > 0 and weight_kg <= 100000),
 volume_m3 numeric(10,3) not null check(volume_m3 > 0 and volume_m3 <= 1000),
 cargo_type text not null,
 offered_price bigint not null check(offered_price between 0 and 1000000000),
 status text not null default 'pending' check(status in ('pending','matched','picked_up','delivered','cancelled')),
 check(status not in ('matched','picked_up','delivered') or trip_id is not null)
);
create table public.matches (
 id uuid primary key default gen_random_uuid(),
 order_id uuid not null references public.orders(id),
 trip_id uuid not null,
 service_type text not null default 'cargo' check(service_type='cargo'),
 foreign key(trip_id,service_type) references public.trips(id,service_type),
 status text not null default 'requested' check(status in ('requested','confirmed','rejected','cancelled')),
 unique(order_id,trip_id)
);
create unique index matches_one_confirmed on public.matches(order_id) where status='confirmed';
create table public.trip_stops (
 trip_id uuid not null references public.trips(id),
 stop_index integer not null check(stop_index>=0),
 address text not null,
 location geometry(Point,4326) not null,
 eta timestamptz not null,
 primary key(trip_id,stop_index)
);
create table public.seat_layouts (
 vehicle_id uuid not null references public.vehicles(id),
 seat_code text not null check(length(seat_code) between 1 and 12),
 row_number integer not null check(row_number>=1),
 column_number integer not null check(column_number>=1),
 primary key(vehicle_id,seat_code),
 unique(vehicle_id,row_number,column_number)
);
create table public.tourism_itineraries (
 trip_id uuid primary key,
 service_type text not null default 'tourism' check(service_type='tourism'),
 foreign key(trip_id,service_type) references public.trips(id,service_type),
 title text not null,
 description text not null default '',
 return_trip_id uuid,
 foreign key(return_trip_id,service_type) references public.trips(id,service_type),
 check(return_trip_id is null or return_trip_id<>trip_id)
);
create table public.passenger_bookings (
 id uuid primary key default gen_random_uuid(),
 passenger_id uuid not null references public.users(id),
 trip_id uuid not null,
 service_type text not null check(service_type in ('passenger','tourism')),
 foreign key(trip_id,service_type) references public.trips(id,service_type),
 from_stop integer not null,
 to_stop integer not null check(to_stop>from_stop),
 foreign key(trip_id,from_stop) references public.trip_stops(trip_id,stop_index),
 foreign key(trip_id,to_stop) references public.trip_stops(trip_id,stop_index),
 seats integer not null check(seats between 1 and 100),
 luggage_kg numeric(8,2) not null default 0 check(luggage_kg between 0 and 1000),
 price_vnd bigint not null check(price_vnd between 0 and 1000000000),
 status text not null default 'requested' check(status in ('requested','held','confirmed','cancelled','completed')),
 unique(id,trip_id,from_stop,to_stop)
);
-- Inventory of actual seats assigned to a trip. Populate from verified vehicle layout
-- in a controlled transaction; do not let browser clients create seats.
create table public.trip_seats (
 trip_id uuid not null references public.trips(id),
 seat_code text not null check(length(seat_code) between 1 and 12),
 primary key(trip_id,seat_code)
);
create table public.seat_reservations (
 id uuid primary key default gen_random_uuid(),
 booking_id uuid not null,
 trip_id uuid not null,
 seat_code text not null,
 from_stop integer not null,
 to_stop integer not null check(to_stop>from_stop),
 foreign key(booking_id,trip_id,from_stop,to_stop) references public.passenger_bookings(id,trip_id,from_stop,to_stop),
 foreign key(trip_id,seat_code) references public.trip_seats(trip_id,seat_code),
 status text not null default 'held' check(status in ('held','confirmed','expired','cancelled')),
 expires_at timestamptz,
 check(status<>'held' or expires_at is not null),
 -- Expired holds must be transitioned to expired before seat reuse in P2.
 exclude using gist (trip_id with =,seat_code with =,int4range(from_stop,to_stop,'[)') with &&)
 where(status in ('held','confirmed'))
);
create table public.vehicle_documents (
 id uuid primary key default gen_random_uuid(),
 vehicle_id uuid not null references public.vehicles(id),
 document_type text not null,
 storage_path text not null unique,
 status text not null default 'pending' check(status in ('pending','approved','rejected'))
);
create table public.order_events (
 id uuid primary key default gen_random_uuid(),
 order_id uuid not null references public.orders(id),
 event_type text not null,
 created_at timestamptz not null default now()
);
create index trips_route_gist on public.trips using gist((route_polyline::geography));
create index orders_pickup_gist on public.orders using gist((ST_SetSRID(ST_MakePoint(pickup_lng,pickup_lat),4326)::geography));
create index orders_dropoff_gist on public.orders using gist((ST_SetSRID(ST_MakePoint(dropoff_lng,dropoff_lat),4326)::geography));
create index trips_driver on public.trips(driver_id);
create index trips_search on public.trips(service_type,status,departure_time);
create index orders_shipper on public.orders(shipper_id);
create index orders_search on public.orders(status,pickup_from,pickup_until);
create index bookings_passenger on public.passenger_bookings(passenger_id);
create index matches_trip on public.matches(trip_id);

-- Deny writes by default; future API must authenticate and authorize all writes.
-- No public listing of precise customer addresses or private documents.
do $$
declare t text;
begin
 foreach t in array array['users','vehicles','trips','orders','matches','trip_stops','seat_layouts','tourism_itineraries','passenger_bookings','trip_seats','seat_reservations','vehicle_documents','order_events'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('revoke all on public.%I from public, anon, authenticated',t);
  execute format('grant select, insert, update, delete on public.%I to service_role',t);
  execute format('grant select on public.%I to authenticated',t);
 end loop;
end $$;
create policy users_own on public.users for select to authenticated using(id=(select auth.uid()));
create policy vehicles_own on public.vehicles for select to authenticated using(driver_id=(select auth.uid()));
create policy trips_own on public.trips for select to authenticated using(driver_id=(select auth.uid()));
create policy orders_own on public.orders for select to authenticated using(shipper_id=(select auth.uid()));
create policy bookings_own on public.passenger_bookings for select to authenticated using(passenger_id=(select auth.uid()));
create policy matches_shipper on public.matches for select to authenticated using(exists(select 1 from public.orders o where o.id=order_id and o.shipper_id=(select auth.uid())));
create policy matches_driver on public.matches for select to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.driver_id=(select auth.uid())));
create policy stops_driver on public.trip_stops for select to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.driver_id=(select auth.uid())));
create policy layout_driver on public.seat_layouts for select to authenticated using(exists(select 1 from public.vehicles v where v.id=vehicle_id and v.driver_id=(select auth.uid())));
create policy tourism_driver on public.tourism_itineraries for select to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.driver_id=(select auth.uid())));
create policy seats_driver on public.trip_seats for select to authenticated using(exists(select 1 from public.trips t where t.id=trip_id and t.driver_id=(select auth.uid())));
create policy reservations_passenger on public.seat_reservations for select to authenticated using(exists(select 1 from public.passenger_bookings b where b.id=booking_id and b.passenger_id=(select auth.uid())));
create policy documents_driver on public.vehicle_documents for select to authenticated using(exists(select 1 from public.vehicles v where v.id=vehicle_id and v.driver_id=(select auth.uid())));
create policy events_shipper on public.order_events for select to authenticated using(exists(select 1 from public.orders o where o.id=order_id and o.shipper_id=(select auth.uid())));
commit;
