import test from "node:test";
import assert from "node:assert/strict";
import {itineraryFor} from "../src/app/itinerary.mjs";
test("sample tourism stops are ordered and include endpoints",()=>{
 for(const [id,end] of [["T1","Hạ Long"],["T2","Ninh Bình"]]){
  const stops=itineraryFor(id);
  assert.equal(stops.length,3);
  assert.equal(stops[0].place,"Hà Nội");
  assert.equal(stops.at(-1).place,end);
  assert.deepEqual(stops.map(s=>s.time),stops.map(s=>s.time).sort());
 }
});
test("unknown and inherited IDs have no itinerary",()=>{
 for(const id of ["P1","unknown","__proto__","constructor"]) assert.deepEqual(itineraryFor(id),[]);
});
