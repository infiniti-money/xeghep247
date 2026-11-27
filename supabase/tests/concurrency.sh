#!/usr/bin/env bash
set -euo pipefail
: "${DB_CONTAINER:?}"
db() { docker exec -i "$DB_CONTAINER" psql -X -v ON_ERROR_STOP=1 -U postgres -d xeghep_test "$@"; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
db < supabase/tests/concurrency_fixture.sql
# First session holds a trip lock and a seat until commit. Second must wait and fail.
db >"$tmp/first" 2>&1 <<'SQL' &
begin;
select hold_booking_seats('00000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001',array['A1']);
select pg_sleep(5);
commit;
SQL
first=$!
ready=0
for i in $(seq 1 40); do
 if db -Atc "select count(*) from pg_stat_activity where pid<>pg_backend_pid() and query='select pg_sleep(5);' and state='active'" | grep -qx 1; then ready=1; break; fi
 sleep .1
done
if [ "$ready" != 1 ]; then wait "$first" || true; cat "$tmp/first"; exit 1; fi
if db >"$tmp/second" 2>&1 <<'SQL'
set statement_timeout='15s';
select hold_booking_seats('00000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000003',array['A1']);
SQL
then wait "$first"; echo 'overlapping booking unexpectedly succeeded'; exit 1; fi
wait "$first"
grep -q 'capacity_exceeded' "$tmp/second"
db <<'SQL'
do $$begin
 if (select count(*) from public.seat_reservations where status='held')<>1 then raise exception 'unexpected active hold count'; end if;
 if (select status from public.passenger_bookings where id='30000000-0000-0000-0000-000000000003')<>'requested' then raise exception 'losing booking changed'; end if;
end$$;
select hold_booking_seats('00000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000002',array['A1']);
SQL
echo 'Concurrent overlapping hold rejected; adjacent segment accepted.'
