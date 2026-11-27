begin;
set local search_path=public,extensions,pg_catalog;
insert into auth.users values ('00000000-0000-0000-0000-000000000001'),('00000000-0000-0000-0000-000000000002');
insert into users(id,full_name,role) values ('00000000-0000-0000-0000-000000000001','Driver','driver'),('00000000-0000-0000-0000-000000000002','Passenger','passenger');
insert into vehicles(id,driver_id,license_plate,vehicle_type,passenger_seats,passenger_eligible) values ('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','TEST-02','van',1,true);
insert into trips(id,driver_id,vehicle_id,service_type,origin_address,origin_lat,origin_lng,dest_address,dest_lat,dest_lng,route_polyline,departure_time,estimated_arrival_time,available_seats) values ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','tourism','A',21,105,'B',21.5,106,ST_GeomFromText('LINESTRING(105 21,106 21.5)',4326),now()+interval '1 day',now()+interval '1 day 2 hours',1);
insert into trip_stops select '20000000-0000-0000-0000-000000000001',i,'Stop '||i,ST_SetSRID(ST_MakePoint(105+i*0.3,21+i*0.15),4326),now()+interval '1 day'+i*interval '30 minutes' from generate_series(0,3) i;
insert into seat_layouts values ('10000000-0000-0000-0000-000000000001','A1',1,1);
insert into trip_seats values ('20000000-0000-0000-0000-000000000001','A1');
insert into passenger_bookings(id,passenger_id,trip_id,service_type,from_stop,to_stop,seats,price_vnd) values
('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','tourism',0,2,1,100000),
('30000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','tourism',2,3,1,100000),
('30000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','tourism',1,2,1,100000);
do $$declare a uuid:='00000000-0000-0000-0000-000000000002'; b uuid:='30000000-0000-0000-0000-000000000001'; c uuid:='30000000-0000-0000-0000-000000000002'; d uuid:='30000000-0000-0000-0000-000000000003'; deadline timestamptz;
begin
 deadline:=hold_booking_seats(a,b,array['A1']);
 if deadline<>hold_booking_seats(a,b,array['A1']) then raise exception 'retry changed deadline'; end if;
 perform hold_booking_seats(a,c,array['A1']);
 begin perform hold_booking_seats(a,d,array['A1']); raise exception 'overlap accepted'; exception when raise_exception then if sqlerrm<>'capacity_exceeded' then raise; end if; end;
 update seat_reservations set expires_at=clock_timestamp()-interval '1 second' where booking_id=b;
 perform hold_booking_seats(a,d,array['A1']);
 if (select status from passenger_bookings where id=b)<>'requested' then raise exception 'expiry state'; end if;
 perform cancel_booking_seats(a,d); perform cancel_booking_seats(a,d);
 if exists(select 1 from seat_reservations where booking_id=d and status in ('held','confirmed')) then raise exception 'cancel failed'; end if;
 perform hold_booking_seats(a,b,array['A1']);
 if has_function_privilege('authenticated','public.hold_booking_seats(uuid,uuid,text[])','execute') then raise exception 'client privilege'; end if;
 begin perform cancel_booking_seats('00000000-0000-0000-0000-000000000001',b); raise exception 'wrong actor accepted'; exception when raise_exception then if sqlerrm<>'booking_not_found' then raise; end if; end;
end $$;
rollback;
