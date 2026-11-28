"use client";
import {useState} from "react";
type Mode="passenger"|"cargo"|"tourism";
type View="home"|"activity"|"driver"|"account";
const modes:{id:Mode;title:string;desc:string;icon:string}[]=[{id:"passenger",title:"Xe ghép",desc:"Đi chung, đưa đón tận nơi",icon:"🚗"},{id:"cargo",title:"Gửi hàng",desc:"Ghép hàng dọc tuyến",icon:"📦"},{id:"tourism",title:"Ghế du lịch",desc:"Ghép đoàn, limousine",icon:"🚌"}];
const normalize=(s:string)=>s.normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/đ/g,"d").toLowerCase().trim();
const nav:{id:View;label:string;icon:string}[]=[{id:"home",label:"Trang chủ",icon:"⌂"},{id:"activity",label:"Chuyến của tôi",icon:"▤"},{id:"driver",label:"Đăng chuyến",icon:"＋"},{id:"account",label:"Tài khoản",icon:"◎"}];
export default function Home(){
 const [mode,setMode]=useState<Mode>("passenger"),[view,setView]=useState<View>("home");
 const [origin,setOrigin]=useState(""),[destination,setDestination]=useState(""),[date,setDate]=useState(""),[quantity,setQuantity]=useState("1"),[volume,setVolume]=useState("0.1"),[round,setRound]=useState(false),[returnDate,setReturnDate]=useState("");
 const [message,setMessage]=useState("");
 function reset(){setMessage("");}
 function changeMode(m:Mode){setMode(m);setQuantity("1");setRound(false);reset();}
 function go(v:View){setView(v);setMessage("");}
 function search(e:React.FormEvent){e.preventDefault();setMessage("");if(!origin.trim()||!destination.trim()||normalize(origin)===normalize(destination)){setMessage("Vui lòng nhập hai địa điểm khác nhau.");return;}if(round&&mode==="tourism"&&returnDate<date){setMessage("Ngày về phải từ ngày đi trở đi.");return;}setMessage("Dịch vụ tìm chuyến chưa kết nối. Vui lòng quay lại sau.");}
 return <div className="app-shell"><header className="topbar"><a className="brand" href="#" onClick={e=>{e.preventDefault();go("home")}}><span className="brand-mark">X</span><span>XeGhép<span className="brand-accent">247</span><small>Đi cùng nhau, tiết kiệm hơn</small></span></a><span className="demo-tag">ĐANG PHÁT TRIỂN</span></header>
 <main className="content">
 <div className="notice" role="note"><strong>Dịch vụ chưa mở</strong> · Hệ thống chưa kết nối dữ liệu vận hành. Chưa nhận đặt xe hoặc đăng chuyến.</div>
 {view==="home"&&<><section className="hero"><div className="eyebrow">DI CHUYỂN THÔNG MINH</div><h1>Mọi hành trình,<br/>đều có bạn đồng hành.</h1><p>Ghép người, ghép hàng, ghép ghế du lịch trên cùng một nền tảng.</p><div className="hero-road" aria-hidden="true">🚗 ━ ━ ━ 📍</div></section>
 <div className="service-grid">{modes.map(m=><button key={m.id} type="button" aria-pressed={m.id===mode} className={"service "+(m.id===mode?"active":"")} onClick={()=>changeMode(m.id)}><span className="service-icon">{m.icon}</span><strong>{m.title}</strong><small>{m.desc}</small></button>)}</div>
 <section className="panel"><h2>Tìm chuyến phù hợp</h2><form onSubmit={search} className="form-grid">
 <label>Điểm đón / lấy hàng<input required value={origin} onChange={e=>{setOrigin(e.target.value);reset()}} placeholder="Ví dụ: Hà Nội"/></label>
 <label>Điểm đến / trả hàng<input required value={destination} onChange={e=>{setDestination(e.target.value);reset()}} placeholder="Ví dụ: Hưng Yên"/></label>
 <label>Ngày đi<input required type="date" value={date} onChange={e=>{setDate(e.target.value);reset()}}/></label>
 <label>{mode==="cargo"?"Khối lượng (kg)":"Số hành khách"}<input required type="number" min={mode==="cargo"?0.1:1} max={mode==="cargo"?10000:16} step={mode==="cargo"?0.1:1} value={quantity} onChange={e=>{setQuantity(e.target.value);reset()}}/></label>
 {mode==="cargo"&&<label>Thể tích (m³)<input required type="number" min="0.01" step="0.01" value={volume} onChange={e=>{setVolume(e.target.value);reset()}}/></label>}
 {mode==="tourism"&&<label>Hành trình<select value={round?"round":"one"} onChange={e=>{setRound(e.target.value==="round");reset()}}><option value="one">Một chiều</option><option value="round">Khứ hồi</option></select></label>}
 {mode==="tourism"&&round&&<label>Ngày về<input type="date" required min={date} value={returnDate} onChange={e=>{setReturnDate(e.target.value);reset()}}/></label>}
 <button className="primary full" type="submit">⌕ Tìm chuyến</button></form>
 </section>
 <section className="panel"><h2>Khám phá dịch vụ</h2><div className="feature-grid">{["Xe tiện chuyến","Bao xe riêng","Gửi hàng liên tỉnh","Ghép đoàn du lịch","Xe chiều về","Đưa đón sân bay"].map(x=><span key={x}>{x}</span>)}</div></section></>}
 {view==="activity"&&<section className="panel"><h1>Chuyến của tôi</h1><p>Đăng nhập khi hệ thống xác thực sẵn sàng để xem lịch sử chuyến.</p></section>}
 {view==="driver"&&<section className="panel"><h1>Đăng chuyến xe</h1><p role="status">Chưa thể đăng chuyến. Cần kết nối tài khoản và API vận hành.</p><button className="primary" disabled>Đăng chuyến</button></section>}
 {view==="account"&&<section className="panel"><h1>Tài khoản</h1><p role="status">Hệ thống xác thực chưa sẵn sàng.</p><button className="primary" disabled>Đăng nhập</button></section>}
 {message&&<p role="status" className="notice">{message}</p>}
 <footer>XeGhép247 · Hệ thống đang phát triển · Chưa nhận giao dịch.</footer></main>
 <nav className="bottom-nav" aria-label="Điều hướng chính">{nav.map(n=><button key={n.id} aria-current={view===n.id?"page":undefined} className={view===n.id?"current":""} onClick={()=>go(n.id)}><span aria-hidden="true">{n.icon}</span><small>{n.label}</small></button>)}</nav></div>
}
