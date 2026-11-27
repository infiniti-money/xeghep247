begin;
alter table public.passenger_bookings add column passenger_confirmed_at timestamptz, add column driver_confirmed_at timestamptz;
-- All confirmation and cancellation operations use the same trip-first lock order.
create function public.confirm_booking_seats(p_actor uuid,p_booking uuid)
returns text language plpgsql security invoker set search_path=pg_catalog,public as $$
declare b public.passenger_bookings%rowtype; t public.trips%rowtype; v public.vehicles%rowtype; n integer;
begin
 select * into b from public.passenger_bookings where id=p_booking;
 if not found then raise exception 'booking_not_found'; end if;
 select * into t from public.trips where id=b.trip_id for update;
 select * into b from public.passenger_bookings where id=p_booking for update;
 if p_actor is null or (p_actor<>b.passenger_id and p_actor<>t.driver_id) then raise exception 'booking_not_found'; end if;
 if b.status='confirmed' then return 'confirmed'; end if;
 select * into v from public.vehicles where id=t.vehicle_id for share;
 if t.status<>'open' or t.departure_time<=clock_timestamp() or not v.passenger_eligible then raise exception 'trip_unavailable'; end if;
 if b.status<>'held' then raise exception 'booking_state'; end if;
 select count(*) into n from public.seat_reservations where booking_id=b.id and status='held' and expires_at>clock_timestamp();
 if n<>b.seats then raise exception 'hold_expired'; end if;
 update public.passenger_bookings set
 passenger_confirmed_at=case when p_actor=b.passenger_id then coalesce(passenger_confirmed_at,clock_timestamp()) else passenger_confirmed_at end,
 driver_confirmed_at=case when p_actor=t.driver_id and p_actor<>b.passenger_id then coalesce(driver_confirmed_at,clock_timestamp()) else driver_confirmed_at end
 where id=b.id returning * into b;
 if b.passenger_confirmed_at is not null and b.driver_confirmed_at is not null then
 update public.seat_reservations set status='confirmed' where booking_id=b.id and status='held';
 update public.passenger_bookings set status='confirmed' where id=b.id;
 return 'confirmed';
 end if;
 return 'held';
end $$;
-- Reset approvals whenever an expired hold is returned to requested.
create function public.reset_booking_approvals() returns trigger language plpgsql security invoker set search_path=pg_catalog,public as $$
begin
 if new.status in ('requested','cancelled') then new.passenger_confirmed_at:=null;new.driver_confirmed_at:=null;end if;
 return new;
end $$;
create trigger reset_booking_approvals before update of status on public.passenger_bookings for each row execute function public.reset_booking_approvals();
revoke all on function public.confirm_booking_seats(uuid,uuid),public.reset_booking_approvals() from public,anon,authenticated;
grant execute on function public.confirm_booking_seats(uuid,uuid) to service_role;
commit;
