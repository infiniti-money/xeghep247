begin;
-- Trusted backend only. Actor must come from verified authentication, never request body.
-- All lifecycle operations serialize on trip row; exclusion constraint remains a backstop.
create function public.hold_booking_seats(p_actor uuid,p_booking uuid,p_codes text[])
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
 deadline:=clock_timestamp()+interval '10 minutes';
 insert into public.seat_reservations(booking_id,trip_id,seat_code,from_stop,to_stop,status,expires_at)
 select b.id,t.id,x,b.from_stop,b.to_stop,'held',deadline from unnest(p_codes) x;
 update public.passenger_bookings set status='held' where id=b.id;
 return deadline;
end $$;
create function public.cancel_booking_seats(p_actor uuid,p_booking uuid)
returns boolean language plpgsql security invoker set search_path=pg_catalog,public as $$
declare b public.passenger_bookings%rowtype;
begin
 select * into b from public.passenger_bookings where id=p_booking and passenger_id=p_actor;
 if not found then raise exception 'booking_not_found'; end if;
 perform 1 from public.trips where id=b.trip_id for update;
 select * into b from public.passenger_bookings where id=p_booking and passenger_id=p_actor for update;
 if not found then raise exception 'booking_not_found'; end if;
 if b.status='cancelled' then return true; end if;
 if b.status not in ('requested','held','confirmed') then raise exception 'booking_state'; end if;
 if exists(select 1 from public.trips where id=b.trip_id and (status<>'open' or departure_time<=clock_timestamp())) then raise exception 'trip_unavailable'; end if;
 update public.seat_reservations set status='cancelled' where booking_id=b.id and status in ('held','confirmed');
 update public.passenger_bookings set status='cancelled' where id=b.id;
 return true;
end $$;
revoke all on function public.hold_booking_seats(uuid,uuid,text[]),public.cancel_booking_seats(uuid,uuid) from public,anon,authenticated;
grant execute on function public.hold_booking_seats(uuid,uuid,text[]),public.cancel_booking_seats(uuid,uuid) to service_role;
commit;
