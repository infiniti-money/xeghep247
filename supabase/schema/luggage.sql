begin;
-- Zero by default: luggage is not accepted until vehicle capacity is configured.
alter table public.vehicles add column max_luggage_kg numeric(8,2) not null default 0 check(max_luggage_kg between 0 and 10000);
create or replace function public.hold_booking_seats(p_actor uuid,p_booking uuid,p_codes text[])
returns timestamptz language plpgsql security invoker set search_path=pg_catalog,public,extensions as $$
declare b public.passenger_bookings%rowtype; t public.trips%rowtype; v public.vehicles%rowtype; deadline timestamptz; n integer;
begin
 select * into b from public.passenger_bookings where id=p_booking and passenger_id=p_actor;
 if not found then raise exception 'booking_not_found'; end if;
 select * into t from public.trips where id=b.trip_id for update;
 select * into b from public.passenger_bookings where id=p_booking and passenger_id=p_actor for update;
 if not found then raise exception 'booking_not_found'; end if;
 select * into v from public.vehicles where id=t.vehicle_id for share;
 if t.status<>'open' or t.departure_time<=clock_timestamp() or not v.passenger_eligible or t.service_type not in ('passenger','tourism') then raise exception 'trip_unavailable'; end if;
 if b.status not in ('requested','held') then raise exception 'booking_state'; end if;
 if p_codes is null or cardinality(p_codes)<>b.seats or b.seats>v.passenger_seats or b.seats>t.available_seats then raise exception 'invalid_seats'; end if;
 select count(distinct x) into n from unnest(p_codes) x;
 if n<>b.seats then raise exception 'invalid_seats'; end if;
 if (select count(*) from public.trip_seats s join public.seat_layouts l on l.vehicle_id=v.id and l.seat_code=s.seat_code where s.trip_id=t.id and s.seat_code=any(p_codes))<>b.seats then raise exception 'invalid_inventory'; end if;
 -- Capacity is checked per segment, not globally decremented: adjacent legs can reuse seats.
 update public.seat_reservations set status='expired' where trip_id=t.id and status='held' and expires_at<=clock_timestamp();
 update public.passenger_bookings q set status='requested' where q.trip_id=t.id and q.status='held' and not exists(select 1 from public.seat_reservations r where r.booking_id=q.id and r.status='held');
 if exists(select 1 from public.seat_reservations where booking_id=b.id and status='held') then
  if (select array_agg(seat_code order by seat_code) from public.seat_reservations where booking_id=b.id and status='held')=(select array_agg(x order by x) from unnest(p_codes) x) then
   return (select min(expires_at) from public.seat_reservations where booking_id=b.id and status='held');
  end if;
  raise exception 'active_hold_exists';
 end if;
 if exists(select 1 from public.trip_stops s where s.trip_id=t.id and s.stop_index>=b.from_stop and s.stop_index<b.to_stop and
 (select count(*) from public.seat_reservations r where r.trip_id=t.id and r.status in ('held','confirmed') and r.from_stop<=s.stop_index and r.to_stop>s.stop_index)+b.seats>least(v.passenger_seats,t.available_seats)) then raise exception 'capacity_exceeded'; end if;
 if exists(select 1 from public.trip_stops s where s.trip_id=t.id and s.stop_index>=b.from_stop and s.stop_index<b.to_stop and
 coalesce((select sum(q.luggage_kg) from public.passenger_bookings q where q.trip_id=t.id and q.id<>b.id and q.from_stop<=s.stop_index and q.to_stop>s.stop_index and exists(select 1 from public.seat_reservations r where r.booking_id=q.id and r.status in ('held','confirmed'))),0)+b.luggage_kg>v.max_luggage_kg) then raise exception 'luggage_capacity_exceeded'; end if;
 deadline:=clock_timestamp()+interval '10 minutes';
 insert into public.seat_reservations(booking_id,trip_id,seat_code,from_stop,to_stop,status,expires_at)
 select b.id,t.id,x,b.from_stop,b.to_stop,'held',deadline from unnest(p_codes) x;
 update public.passenger_bookings set status='held' where id=b.id;
 return deadline;
end $$;

commit;
