import test from 'node:test';
import assert from 'node:assert/strict';
import {estimateDemoFare} from '../src/app/fare.mjs';
test('one-way passenger and fractional cargo',()=>{assert.equal(estimateDemoFare(120000,2),240000);assert.equal(estimateDemoFare(4000,1.5),6000);});
test('round-trip demo includes both directions',()=>{assert.equal(estimateDemoFare(250000,3,true),1500000);});
