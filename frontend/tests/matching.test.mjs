import test from "node:test";
import assert from "node:assert/strict";
import {eligibleMatch,canReserveSeat} from "../src/domain/matching.mjs";
const trip={status:"open",service:"cargo",availableWeight:100,availableVolume:2};
const request={service:"cargo",pickupDistance:500,dropoffDistance:10000,pickupFraction:.2,dropoffFraction:.8,pickupEta:100,pickupFrom:90,pickupUntil:110,weight:100,volume:2};
test("cargo matches at boundary",()=>assert.equal(eligibleMatch(trip,request),true));
for(const patch of [{weight:101},{volume:3},{pickupDistance:10001},{pickupFraction:.9},{pickupEta:111},{weight:NaN},{weight:-1},{pickupFrom:101},{dropoffFraction:1.1},{service:"passenger"}])test("reject "+JSON.stringify(patch),()=>assert.equal(eligibleMatch(trip,{...request,...patch}),false));
test("passengers require eligible vehicle and seats",()=>{const p={...trip,service:"passenger",availableSeats:2,passengerEligible:true};const r={...request,service:"passenger",seats:2};assert.equal(eligibleMatch(p,r),true);assert.equal(eligibleMatch({...p,passengerEligible:false},r),false);assert.equal(eligibleMatch(p,{...r,seats:3}),false);});
test("tourism seat segment overlap",()=>{const r={seat:"A1",from:1,to:3,status:"confirmed"};assert.equal(canReserveSeat([r],{seat:"A1",from:2,to:4},100),false);assert.equal(canReserveSeat([r],{seat:"A1",from:3,to:4},100),true);assert.equal(canReserveSeat([{...r,status:"held",expiresAt:99}],{seat:"A1",from:2,to:4},100),true);assert.equal(canReserveSeat([{...r,status:"held",expiresAt:101}],{seat:"A1",from:2,to:4},100),false);assert.equal(canReserveSeat([],{seat:"A1",from:4,to:2},100),false);});
