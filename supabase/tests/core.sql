begin;
set local search_path=public,extensions,pg_catalog;
insert into auth.users values ('00000000-0000-0000-0000-000000000001'),('00000000-0000-0000-0000-000000000002'),('00000000-0000-0000-0000-000000000003');
insert into users(id,full_name,role) values ('00000000-0000-0000-0000-000000000001','Driver','driver'),('00000000-0000-0000-0000-000000000002','Passenger','passenger'),('00000000-0000-0000-0000-000000000003','Other','shipper');
insert into vehicles(id,driver_id,license_plate,vehicle_type,passenger_seats,passenger_eligible) values ('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','TEST-01','van',9,true);
insert into trips(id,driver_id,vehicle_id,service_type,origin_address,origin_lat,origin_lng,dest_address,dest_lat,dest_lng,route_polyline,departure_time,estimated_arrival_time,available_seats) values ('20000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','tourism','A',21,105,'B',21.5,106,ST_GeomFromText('LINESTRING(105 21,106 21.5)',4326),now()+interval '1 day',now()+interval '1 day 2 hours',9);
insert into trip_stops select '20000000-0000-0000-0000-000000000001',i,'Stop '||i,ST_SetSRID(ST_MakePoint(105+i*0.3,21+i*0.15),4326),now()+interval '1 day'+i*interval '30 minutes' from generate_series(0,3) i;
insert into trip_seats values ('20000000-0000-0000-0000-000000000001','A1');
insert into passenger_bookings(id,passenger_id,trip_id,service_type,from_stop,to_stop,seats,price_vnd) values
('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','tourism',0,2,1,100000),
('30000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','tourism',2,3,1,100000),
('30000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','tourism',1,3,1,100000);
insert into seat_reservations(booking_id,trip_id,seat_code,from_stop,to_stop,status) values
('30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1',0,2,'confirmed'),
('30000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1',2,3,'confirmed');
do $$begin
 begin
 insert into seat_reservations(booking_id,trip_id,seat_code,from_stop,to_stop,status) values ('30000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1',1,3,'confirmed');
 raise exception 'overlap accepted';
 exception when exclusion_violation then null;
 end;
 begin
 update trips set available_seats=-1;
 raise exception 'negative capacity accepted';
 exception when check_violation then null;
 end;
 if not ST_DWithin(ST_GeomFromText('LINESTRING(105 21,106 21.5)',4326)::geography,ST_SetSRID(ST_MakePoint(105,21),4326)::geography,10000) then raise exception 'geography test failed';end if;
end$$;
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
do $$begin
 if (select count(*) from users)<>1 then raise exception 'profile RLS failed';end if;
 if (select count(*) from passenger_bookings)<>2 then raise exception 'booking RLS failed';end if;
 if (select count(*) from seat_reservations)<>2 then raise exception 'reservation RLS failed';end if;
 if (select count(*) from trips)<>0 then raise exception 'trip RLS leaked';end if;
 begin
 update users set role='admin';
 raise exception 'role escalation accepted';
 exception when insufficient_privilege then null;
 end;
end$$;
reset role;
set local role anon;
do $$begin
 begin
 perform count(*) from public.users;
 raise exception 'anonymous access accepted';
 exception when insufficient_privilege then null;
 end;
end$$;
reset role;
rollback;
