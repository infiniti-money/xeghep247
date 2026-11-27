// Pure prefilter only; authoritative capacity and bookings must be checked in a database transaction.
export function eligibleMatch(trip, request, corridorMeters=10000){
 const valid=(n)=>typeof n==="number"&&Number.isFinite(n)&&n>=0;
 if(!valid(corridorMeters)||trip.status!=="open"||trip.service!==request.service)return false;
 if(!["cargo","passenger","tourism"].includes(trip.service))return false;
 if(![request.pickupDistance,request.dropoffDistance,request.pickupFraction,request.dropoffFraction,request.pickupEta,request.pickupFrom,request.pickupUntil].every(valid))return false;
 if(request.pickupDistance>corridorMeters||request.dropoffDistance>corridorMeters||request.pickupFraction>=request.dropoffFraction||request.dropoffFraction>1||request.pickupEta<request.pickupFrom||request.pickupEta>request.pickupUntil)return false;
 if(trip.service==="cargo")return [request.weight,request.volume,trip.availableWeight,trip.availableVolume].every(valid)&&request.weight>0&&request.volume>0&&request.weight<=trip.availableWeight&&request.volume<=trip.availableVolume;
 return trip.passengerEligible===true&&Number.isSafeInteger(request.seats)&&request.seats>0&&Number.isSafeInteger(trip.availableSeats)&&request.seats<=trip.availableSeats;
}
// Half-open intervals [from,to): adjacent legs can reuse a seat, overlapping legs cannot.
export function canReserveSeat(reservations,requested,now){
 const valid=r=>Number.isSafeInteger(r.from)&&Number.isSafeInteger(r.to)&&r.from>=0&&r.to>r.from&&typeof r.seat==="string"&&r.seat.length>0;
 if(!valid(requested)||!Number.isFinite(now)||!reservations.every(valid))return false;
 return !reservations.some(r=>r.seat===requested.seat&&r.from<requested.to&&requested.from<r.to&&(r.status==="confirmed"||(r.status==="held"&&r.expiresAt>now)));
}
