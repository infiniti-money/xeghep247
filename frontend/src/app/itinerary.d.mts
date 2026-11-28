export function itineraryFor(id:string): {place:string;time:string}[];

export function validSegment(stops: {place:string;time:string}[], pickup:number, dropoff:number): boolean;
