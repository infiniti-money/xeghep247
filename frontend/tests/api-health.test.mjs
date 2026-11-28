import test from "node:test";
import assert from "node:assert/strict";
import {checkApi} from "../src/app/api-health.mjs";
const base="https://api.example.com";
const response=(body,status=200)=>async()=>Response.json(body,{status});
test("missing or unsafe configuration never fetches",async()=>{
 for(const url of ["","http://api.example.com","https://u:p@api.example.com","https://api.example.com/path","https://api.example.com/?token=x"])
 assert.equal(await checkApi(url,{fetcher:()=>{throw Error("unexpected fetch")}}),"unconfigured");
});
test("health distinguishes database readiness",async()=>{
 for(const database of ["ready","not_configured",undefined])
 assert.equal(await checkApi(base,{fetcher:response({service:"xeghep247-api",status:"ok",database})}),database==="ready"?"ready":"database_unavailable");
});
test("rejects wrong service and HTTP failure",async()=>{
 assert.equal(await checkApi(base,{fetcher:response({status:"ok",database:"ready"})}),"unavailable");
 assert.equal(await checkApi(base,{fetcher:response({},503)}),"unavailable");
});
test("timeout aborts request",async()=>{
 assert.equal(await checkApi(base,{timeoutMs:5,fetcher:(_,options)=>new Promise((resolve,reject)=>options.signal.addEventListener("abort",()=>reject(Error("aborted"))))}),"unavailable");
});
