import test from "node:test";
import assert from "node:assert/strict";
import {itineraryFor, validSegment} from "../src/app/itinerary.mjs";
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

test("segments require strictly ordered existing stops",()=>{
 const stops=itineraryFor("T1");
 for(const [a,b] of [[0,1],[0,2],[1,2]]) assert.equal(validSegment(stops,a,b),true);
 for(const [a,b] of [[0,0],[2,1],[-1,1],[0,3],[0.5,2],[0,NaN]]) assert.equal(validSegment(stops,a,b),false);
 assert.equal(validSegment([],0,1),false);
});
