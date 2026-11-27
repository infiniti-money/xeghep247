begin;
set local search_path=public,extensions,pg_catalog;
insert into auth.users values ('00000000-0000-0000-0000-000000000011'),('00000000-0000-0000-0000-000000000012');
insert into users(id,full_name,role) values ('00000000-0000-0000-0000-000000000011','Driver','driver'),('00000000-0000-0000-0000-000000000012','Shipper','shipper');
insert into vehicles(id,driver_id,license_plate,vehicle_type,max_weight_kg,max_volume_m3) values ('10000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000011','TEST-11','truck',100,2);
insert into trips(id,driver_id,vehicle_id,service_type,origin_address,origin_lat,origin_lng,dest_address,dest_lat,dest_lng,route_polyline,departure_time,estimated_arrival_time,available_weight_kg,available_volume_m3) values ('20000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000011','10000000-0000-0000-0000-000000000011','cargo','A',21,105,'B',21,106,ST_GeomFromText('LINESTRING(105 21,106 21)',4326),now()+interval '1 day',now()+interval '1 day 2 hours',100,2);
insert into orders(id,shipper_id,pickup_lat,pickup_lng,pickup_address,dropoff_lat,dropoff_lng,dropoff_address,pickup_from,pickup_until,weight_kg,volume_m3,cargo_type,offered_price) values ('30000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000012',21,105.25,'A',21,105.75,'B',now()+interval '1 day',now()+interval '1 day 1 hour',100,2,'box',100000);
do $$ declare o uuid:='30000000-0000-0000-0000-000000000011'; a uuid:='00000000-0000-0000-0000-000000000012'; begin
if (select count(*) from cargo_candidates(o,a))<>1 then raise exception 'valid candidate missing'; end if;
if (select count(*) from cargo_candidates(o,'00000000-0000-0000-0000-000000000011'))<>0 then raise exception 'ownership leak';end if;
update orders set weight_kg=101 where id=o;
if exists(select 1 from cargo_candidates(o,a)) then raise exception 'overweight';end if;
update orders set weight_kg=100,pickup_lng=105.9 where id=o;
if exists(select 1 from cargo_candidates(o,a)) then raise exception 'reverse route';end if;
update orders set pickup_lng=105.25,pickup_lat=22 where id=o;
if exists(select 1 from cargo_candidates(o,a)) then raise exception 'outside corridor';end if;
update orders set pickup_lat=21,pickup_until=pickup_from where id=o;
if exists(select 1 from cargo_candidates(o,a)) then raise exception 'ETA outside window';end if;
end $$;
set local role authenticated;
do $$begin
if has_function_privilege(current_user,'public.cargo_candidates(uuid,uuid)','EXECUTE') then raise exception 'RPC exposed';end if;
end$$;
reset role;
rollback;
