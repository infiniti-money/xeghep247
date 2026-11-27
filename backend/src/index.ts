export default {async fetch(request:Request):Promise<Response>{
 const url=new URL(request.url);
 if(request.method==="GET"&&url.pathname==="/health")return Response.json({service:"xeghep247-api",status:"ok",database:"not_configured"},{headers:{"Cache-Control":"no-store"}});
 return Response.json({error:"not_found"},{status:404});
}};
