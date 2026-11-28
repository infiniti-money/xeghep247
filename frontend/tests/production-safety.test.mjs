import {test} from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
const page=readFileSync(new URL("../src/app/page.tsx",import.meta.url),"utf8");
test("public UI fails closed before backend integration",()=>{assert.match(page,/Dịch vụ tìm chuyến chưa kết nối/);assert.match(page,/<button className="primary" disabled>Đăng chuyến/);assert.match(page,/<button className="primary" disabled>Đăng nhập/);assert.doesNotMatch(page,/sample\.filter|setDrafts|Vai trò minh họa|Bận mẫu/);});
