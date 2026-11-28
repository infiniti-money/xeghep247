import test from "node:test";
import assert from "node:assert/strict";
import {actionsForRole} from "../src/app/roles.mjs";
test("role shortcuts target the correct service",()=>{
 assert.equal(actionsForRole("Chủ hàng")[0].mode,"cargo");
 assert.equal(actionsForRole("Nhà xe")[0].mode,"tourism");
 assert.equal(actionsForRole("Tài xế")[0].view,"driver");
 assert.equal(actionsForRole("Hành khách")[0].view,"home");
});
test("admin and unknown roles have no operational shortcuts",()=>{
 for(const role of ["Quản trị","unknown","__proto__","constructor"]) assert.deepEqual(actionsForRole(role),[]);
});
