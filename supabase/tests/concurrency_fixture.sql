set search_path=public,extensions,pg_catalog;
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

