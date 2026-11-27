begin;
-- Server-only candidate lookup; no customer addresses returned.
create function public.cargo_candidates(p_order uuid,p_actor uuid)
returns table(trip_id uuid,pickup_eta timestamptz,pickup_distance_m double precision,dropoff_distance_m double precision)
language sql stable security invoker set search_path=pg_catalog,public,extensions as $$
 select t.id, e.eta, d.pd,d.dd
 from public.orders o join public.trips t on t.service_type='cargo'
 join public.vehicles v on v.id=t.vehicle_id
 cross join lateral (select ST_SetSRID(ST_MakePoint(o.pickup_lng,o.pickup_lat),4326) p,ST_SetSRID(ST_MakePoint(o.dropoff_lng,o.dropoff_lat),4326) q) g
 cross join lateral (select ST_LineLocatePoint(t.route_polyline,g.p) a,ST_LineLocatePoint(t.route_polyline,g.q) b) f
 cross join lateral (select t.departure_time+(t.estimated_arrival_time-t.departure_time)*f.a eta) e
 cross join lateral (select ST_Distance(t.route_polyline::geography,g.p::geography) pd,ST_Distance(t.route_polyline::geography,g.q::geography) dd) d
 where o.id=p_order and o.shipper_id=p_actor and o.status='pending'
 and t.status='open' and t.departure_time>=now()
 and o.weight_kg<=least(t.available_weight_kg,v.max_weight_kg)
 and o.volume_m3<=least(t.available_volume_m3,v.max_volume_m3)
 and ST_DWithin(t.route_polyline::geography,g.p::geography,10000)
 and ST_DWithin(t.route_polyline::geography,g.q::geography,10000)
 and f.a<f.b and e.eta between o.pickup_from and o.pickup_until
 order by d.pd+d.dd,t.id limit 100
$$;
revoke all on function public.cargo_candidates(uuid,uuid) from public,anon,authenticated;
grant execute on function public.cargo_candidates(uuid,uuid) to service_role;
commit;
